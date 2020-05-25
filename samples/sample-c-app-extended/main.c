#include "isoTime.h"
#include <stdio.h>
#include <unistd.h>

static char currentUtcTime[22];

int main(int argc, char *argv[]) {
  // Disable buffering.
  // Useful when debugging as stdout (printf) buffered by default
  setbuf(stdout, NULL);

  for (int i = 0; i < 100; i++) {
    printf("%s\n", getCurrentUtc(currentUtcTime, sizeof(currentUtcTime)));
    sleep(1);
  }
}
