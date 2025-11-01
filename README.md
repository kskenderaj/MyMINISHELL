# MyMINISHELL

A simple shell implementation in C that mimics basic shell functionality.

## Features

- **Command Execution**: Execute external commands like `ls`, `echo`, `pwd`, `date`, etc.
- **Built-in Commands**:
  - `cd` - Change directory
  - `exit` - Exit the shell
  - `env` - Display environment variables
- **Command Parsing**: Parse commands with multiple arguments
- **Error Handling**: Proper error messages for invalid commands and operations

## Building

To build the minishell, run:

```bash
make
```

To rebuild from scratch:

```bash
make re
```

To clean build artifacts:

```bash
make clean
```

## Usage

Run the minishell:

```bash
./minishell
```

You will see a prompt `minishell>` where you can type commands:

```
minishell> ls -l
minishell> echo Hello World
minishell> cd /tmp
minishell> pwd
minishell> env
minishell> exit
```

## Testing

To test if every command is working properly, run the test script:

```bash
./test_commands.sh
```

This script will:
- Build the minishell
- Test external commands (echo, ls, pwd, date, whoami)
- Test built-in commands (cd, env)
- Test commands with arguments
- Test error handling
- Test edge cases

The test results will show:
- ✓ for passed tests (in green)
- ✗ for failed tests (in red)
- A summary of total tests run, passed, and failed

## Supported Commands

### Built-in Commands
- `cd <directory>` - Change the current working directory
- `exit` - Exit the shell
- `env` - Display all environment variables

### External Commands
Any command available in your system's PATH can be executed, including:
- `ls` - List directory contents
- `echo` - Display a line of text
- `pwd` - Print working directory
- `cat` - Concatenate and display files
- `grep` - Search text patterns
- `date` - Display date and time
- `whoami` - Display current user
- And many more...

## Implementation Details

The minishell is implemented in C and includes:
- **Input Reading**: Uses `getline()` for reading user input
- **Parsing**: Tokenizes input into command and arguments
- **Execution**: 
  - Built-in commands are executed directly
  - External commands are executed using `fork()` and `execvp()`
- **Process Management**: Parent process waits for child processes to complete

## Requirements

- GCC compiler
- POSIX-compliant system (Linux, macOS, etc.)
- Standard C library

## Author

Created for personal use to check and test shell command functionality.