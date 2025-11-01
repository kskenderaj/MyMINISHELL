#include "minishell.h"

extern char **environ;

/* Built-in commands */
char *builtin_str[] = {
    "cd",
    "exit",
    "env"
};

int (*builtin_func[]) (char **) = {
    &builtin_cd,
    &builtin_exit,
    &builtin_env
};

int num_builtins(void) {
    return sizeof(builtin_str) / sizeof(char *);
}

/* Built-in command implementations */
int builtin_cd(char **args) {
    if (args[1] == NULL) {
        fprintf(stderr, "minishell: cd: missing argument\n");
        return 1;
    }
    
    if (chdir(args[1]) != 0) {
        perror("minishell: cd");
    }
    return 1;
}

int builtin_exit(char **args) {
    (void)args;
    exit(0);
}

int builtin_env(char **args) {
    int i = 0;
    
    (void)args;
    while (environ[i] != NULL) {
        printf("%s\n", environ[i]);
        i++;
    }
    return 1;
}

/* Display shell prompt */
void display_prompt(void) {
    printf("minishell> ");
    fflush(stdout);
}

/* Read a line from stdin */
char *read_line(void) {
    char *line = NULL;
    size_t bufsize = 0;
    
    if (getline(&line, &bufsize, stdin) == -1) {
        if (feof(stdin)) {
            free(line);
            exit(0);
        } else {
            perror("minishell: getline");
            free(line);
            exit(1);
        }
    }
    
    return line;
}

/* Parse line into arguments */
char **parse_line(char *line) {
    int bufsize = MAX_ARGS;
    int position = 0;
    char **tokens = malloc(bufsize * sizeof(char*));
    char *token;
    
    if (!tokens) {
        fprintf(stderr, "minishell: allocation error\n");
        exit(1);
    }
    
    token = strtok(line, " \t\r\n\a");
    while (token != NULL) {
        tokens[position] = token;
        position++;
        
        if (position >= bufsize) {
            bufsize += MAX_ARGS;
            tokens = realloc(tokens, bufsize * sizeof(char*));
            if (!tokens) {
                fprintf(stderr, "minishell: allocation error\n");
                exit(1);
            }
        }
        
        token = strtok(NULL, " \t\r\n\a");
    }
    tokens[position] = NULL;
    return tokens;
}

/* Launch a program */
int launch(char **args) {
    pid_t pid;
    int status;
    
    pid = fork();
    if (pid == 0) {
        /* Child process */
        if (execvp(args[0], args) == -1) {
            perror("minishell");
        }
        exit(1);
    } else if (pid < 0) {
        /* Fork error */
        perror("minishell: fork");
    } else {
        /* Parent process */
        do {
            waitpid(pid, &status, WUNTRACED);
        } while (!WIFEXITED(status) && !WIFSIGNALED(status));
    }
    
    return 1;
}

/* Execute command */
int execute(char **args) {
    int i;
    
    if (args[0] == NULL) {
        /* Empty command */
        return 1;
    }
    
    for (i = 0; i < num_builtins(); i++) {
        if (strcmp(args[0], builtin_str[i]) == 0) {
            return (*builtin_func[i])(args);
        }
    }
    
    return launch(args);
}

/* Main shell loop */
void shell_loop(void) {
    char *line;
    char **args;
    int status = 1;
    
    do {
        display_prompt();
        line = read_line();
        args = parse_line(line);
        status = execute(args);
        
        free(line);
        free(args);
    } while (status);
}

/* Main function */
int main(int argc, char **argv) {
    (void)argc;
    (void)argv;
    
    /* Run command loop */
    shell_loop();
    
    return 0;
}
