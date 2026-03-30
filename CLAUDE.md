# Tandem Protocol
@~/projects/tandem-protocol/README.md

### evtctl — project task management

```
evtctl task <description>            # publish a task event
evtctl task --to <project> <desc>    # task for another project
evtctl inbox <app> <message>         # send inbox message
evtctl done <id>[,<id>...] [evidence] # publish a task-done event
evtctl open                          # list open tasks
evtctl audit                         # full task reconciliation
evtctl claim <id> <name>             # claim a task
evtctl claims                        # list active claims
```

Stream name automatically derived from project directory: `tasks.tandem-protocol`.

## Plan Mode Entry (Critical)

When entering plan mode with an existing plan:
1. Quote the existing plan VERBATIM (no summarizing)
2. Grade analysis FIRST: "Do I understand this?"
3. Grade plan quality: "Is this sound?"
4. BLOCKING: Wait for user direction before proceeding

Do not proceed past plan mode without explicit user approval ("proceed", "yes", "approved").
