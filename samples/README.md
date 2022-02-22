# Samples

The files here are taken from larger projects. They aren't meant to stand on
their own, but are extracted as sanitized samples of code I wrote. In all
cases, the code here was at least 90% originally written by me.

## CQRS

Most of these modules were written to integrate into an event-sourced CQRS
[Command Query Responsibility Segregation] system.

[DailyCycler](daily_cycler.ex) is a "cron" server. It is designed to publish
an event once a day, checking once per hour to see if it should run. We opted
for this design because the underlying system can get redeployed daily, and it
is safer to ensure that each date is triggered. This also make it resilient to
extended downtime. This approach schedules the next job upon completion, so
that it is not a strict "run every 60 minutes" job, but will be delayed by
however long it takes to perform its action, thus preventing it from
attempting to run again while the previous run was still active. This isn't
strictly necessary, but we wanted to set the pattern as a precedence in case
we need to use it again.

[Grant](grant.ex) is a command handler. It is typical of our command handlers,
in that it validates all input before publishing a new event. In this case, it
has to reach out to aggregates to ensure that there are sufficient funds for
the event to succeed.

[Membership](membership.ex) is an aggregate. While most other aggregates in
the system are specific to a single `stream_identifier`, this one has to
aggregate across multiple streams of events. It uses ETS to track membership
details. This is not necessarily the most efficient solution, but is good
enough based upon our normal load. This aggregate is tracked in a `Registry`
and initializes as the child of a `DynamicSupervisor` (not seen here).

[Manager](manager.ex), [LateFeeProcessManager](late_fee_process_manager.ex),
and [ProcessManagerHelper](helpers/process_manager_helper.ex) combine to show
the process manager behavior. A "process manager" is not clearly defined
across CQRS patterns, but we use it as an event consumer which can publish new
events in response to other events. Importantly, a process manager should
never process that same event twice, so unlike projectors it should never
rehydrate from the very first event.
- The `Manager` is a behaviour module that other process managers `use`. It
  handles the `GenServer` implementation details. One notable feature is the
  use of `handle_continue` to ensure that hydration occurs before any new
  events come in. Process managers (and projectors) are designed to crash if
  events come in out of sequence, which could happen because of DB issues.
- The `LateFeeProcessManager` is a process manager which listens for the
  "SystemCycled" event (created by the `DailyCycler` above), then creates new
  events for any products which are overdue.
- The `ProcessManagerHelper` captures the rehydration logic used by the
  `Manager`.
- Note that [config.exs](config/config.exs) is include to show where the
  configuration around hydration comes from.

[Projector](projector.ex) is the behaviour module for all projectors. Very
similar to `Manager`, but it allows for two kinds of projection start-up
scenarios, which deals with a legacy issue in the system where some projectors
were originally designed without autonomy in mind. I am not including any
example projectors because they are almost entirely business logic.
