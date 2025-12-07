
# The [no-cd] tag is used to tell Just that this command should
# be executed from the directory where the command is run, not from the
# directory where the justfile is located (This is a 'global' justfile)

[no-cd]
test:
	@echo "Successfully accessed your global justfile from $(pwd)"

# `git reset --hard` is a destructive command that will discard all local changes.
# Use with caution, as it will permanently delete any uncommitted changes.
[no-cd]
git-hard-reset:
	git fetch upstream
	git checkout main
	git reset --hard upstream/main

[no-cd]
prune-branches:
	bash $projects/.scripts/local_branch_pruner.sh

[no-cd]
diff-workflows path:
	bash $projects/.scripts/diff_workflows.sh {{path}}