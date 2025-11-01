#ifndef MINISHELL_H
#define MINISHELL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

#define MAX_INPUT 1024
#define MAX_ARGS 64

/* Function prototypes */
void display_prompt(void);
char *read_line(void);
char **parse_line(char *line);
int execute(char **args);
int builtin_cd(char **args);
int builtin_exit(char **args);
int builtin_env(char **args);

#endif
