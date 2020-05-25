#include "isoTime.h"

char *getCurrentUtc(char *buffer, size_t bufferSize) {
  time_t now = time(NULL);
  struct tm *t = gmtime(&now);
  strftime(buffer, bufferSize - 1, "%Y-%d-%m %H:%M:%S", t);
  return buffer;
}
