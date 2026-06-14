# Terraform state, explained

Companion notes for the [`terraform-remote-state`](../projects/terraform-remote-state) project. Read this if you are not yet sure what "state" even is.

## What is state?

When Terraform creates a resource, it has to remember the link between what you wrote in code and the real thing in the cloud. That memory is the **state file** (`terraform.tfstate`), a JSON document mapping each resource in your config to its real-world ID.

Without state, Terraform would have no idea that the `aws_s3_bucket "state"` in your code is the bucket `tf-state-demo-123` in AWS. State is that bookkeeping.

On the next `plan`, Terraform compares three things: your code, the state, and the real infrastructure. The difference is the plan.

## Why local state hurts on a team

By default the state file lives next to your code on your laptop. That is fine for a solo experiment and painful for a team:

- **Not shared**: your teammate's Terraform cannot see what you created. You each build your own divergent reality.
- **No locking**: if two people apply at once, both write the same file and one set of changes is lost or the file is corrupted.
- **Fragile**: the state often contains secrets (database passwords, generated keys) in plain text. A laptop backup to the wrong place is now a leak.

## What remote state changes

Move the file to a shared, durable location and add a lock:

- **S3 bucket**: one shared copy of state, versioned (so you can roll back a bad write) and encrypted at rest.
- **DynamoDB table**: before any apply, Terraform writes a lock item. Anyone else who tries to apply waits until the lock is released. This is how you prevent two simultaneous applies.

The combination is the de facto standard backend for Terraform on AWS.

## How locking actually works

The DynamoDB table has one required attribute, `LockID`. When you run apply, Terraform does a conditional write: "create this lock item, but only if it does not already exist." If someone else holds the lock, the write fails and Terraform waits and retries, printing `Acquiring state lock`. When the apply finishes, Terraform deletes the lock item. Simple and effective.

If a process dies mid-apply and leaves a stale lock, `terraform force-unlock LOCK_ID` clears it. Use it carefully, only when you are sure no apply is actually running.

## The bootstrap problem

There is a circular dependency: to store state in S3 you need an S3 bucket, but creating that bucket is itself Terraform that needs somewhere to store state. The standard solution, used in this project, is:

1. Create the bucket and lock table with **local state** (the `bootstrap/` step).
2. Optionally migrate the bootstrap's own state into the bucket afterward.
3. Every other project points its backend at that bucket.

You only pay this one-time cost once per account or organization.

## Mental model

- **Code** is what you want.
- **State** is what Terraform thinks exists.
- **The cloud** is what actually exists.
- `plan` is the diff between them; `apply` makes the cloud match the code and updates state.

Keeping state remote, locked, versioned, and encrypted is the difference between Terraform that scales to a team and Terraform that bites you.
