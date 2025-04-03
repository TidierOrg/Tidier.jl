# Tidier.jl updates

## v1.6.1 - 2025-04-03
- Bugfix: `@chain()` is now properly exported, fixing a number of bugs related to chaining functions/macros
- Bugfix: Re-export documentation for TidierData.jl and TidierDB.jl to dispatch macros
- Bugfix: `write_file` is now correctly dispatched between TidierDB.jl and TidierFiles.jl