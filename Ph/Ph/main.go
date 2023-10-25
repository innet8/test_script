#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    pid_t pid = 2349;
    if (setsid() < 0) {
        perror("setsid");
        exit(1);
    }
    if (fork() != 0) {
        exit(0);
    }
    if (setsid() < 0) {
        perror("setsid");
        exit(1);
    }
    if (chdir("/") < 0) {
        perror("chdir");
        exit(1);
    }
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);
  
    return 0;
}
