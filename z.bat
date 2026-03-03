@echo off
set "filename=%~n1"
zig build-exe "%filename%.zig"
if exist "%filename%.pdb" (
    del "%filename%.pdb"
)