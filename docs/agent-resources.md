# Agent resource limits

Run checks and builds directly. Stop temporary processes and containers when the
check finishes or is cancelled. Keep user-requested development servers running
and record how to stop them.

## Agent sessions

Kiln and Linux shell aliases launch coding sessions through `agent-session`.
Each scope has a 3 GiB soft limit, 6 GiB hard limit and 512 MiB swap limit.
Child processes inherit these limits. Existing sessions retain their cgroups.

## Containers

`agent-container [DOCKER RUN OPTIONS...] -- IMAGE [COMMAND...]` runs a container
with 2 GiB RAM, 1 GiB swap and four CPUs in `agent-containers.slice`.
Containers are removed when they exit. The task must stop any detached container
it starts. The system slice caps combined container memory at 6 GiB.

## Installation

Dotter deploys the scripts and user slices. Its root package deploys the
container slice. Reload systemd after changing slice files.
