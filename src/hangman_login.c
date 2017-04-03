/*
  hangman login

  there are a list of words. one will be chosen at random. the user
  will have a certain number of guess
*/

#include <errno.h>
#include <fcntl.h>
#include <linux/input.h>
#include <poll.h>
#include <pwd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#include <security/pam_modules.h>

// map 0,1,2 event code to their name
static const char *const evval[3] = {
  "RELEASED",
  "PRESSED ",
  "REPEATED"
};

// grep command to get the keyboard event number
static const char* CMD_GET_KEYBOARD_DEVICE_EVENT_NUMBER =
  "grep -E 'Handlers|EV=' /proc/bus/input/devices |"
  "grep -B1 'EV=120013' |"
  "grep -Eo 'event[0-9]+' |"
  "grep -Eo '[0-9]+' |"
  "tr -d '\n'";


// call command
// append result to the keyboard string
void set_keyboard_device_number(char* keyboard){
  FILE *pipe = popen(CMD_GET_KEYBOARD_DEVICE_EVENT_NUMBER, "r");
  char buffer[16];
  /* while (!feof(pipe)) */
  if (fgets(buffer, 4, pipe) != NULL)
    strcat(keyboard, buffer);
  printf("%s\n", keyboard);
  pclose(pipe);
}

PAM_EXTERN int
pam_sm_authenticate(pam_handle_t *pamh, int flags,
                    int argc, const char *argv[])
{
  srand(time(NULL));

  const char *username;
  int r;
  struct passwd *passwd;


  /* identify user */
	r = pam_get_user(pamh, &username, NULL);
	if (r != PAM_SUCCESS)
		return PAM_AUTHINFO_UNAVAIL;

  /* check to see if they have a password */
	passwd = getpwnam(username);
	if (!passwd)
		return PAM_AUTHINFO_UNAVAIL;

  int numWords = 5;
  char* words[5] = {"apple", "banana", "grape", "lemon", "orange"};
  char* word = words[rand() % numWords];
  char guessed[20];
  const int MAX_WRONG = 6;
  int wrong = 0;
  int i;

  for(i = 0; i <strlen(word);i++)
    guessed[i] = '_';

  guessed[strlen(word)] = '\0';

  // A to Z
  int charKeycodes[26] =
    {
      30,
      48,
      46,
      32,
      18,
      33,
      34,
      35,
      23,
      36,
      37,
      38,
      50,
      49,
      24,
      25,
      16,
      19,
      31,
      20,
      22,
      47,
      17,
      45,
      21,
      44
    };

  // mouse and keyboard devices
  const char *mouseDevice = "/dev/input/mice"; /* gets input from every mouse */

  // it will be something like /dev/input/event*
  char keyboardDevice[64] = "/dev/input/event";
  set_keyboard_device_number(keyboardDevice); // find and set keyboard event number

  // mouse info
  int mousefd; // file descriptor
  ssize_t mouseBytes; // bytes read
  unsigned char data[3]; // mouse device outputs 3 byte per read
  int left=0, middle=0, right = 0;
  signed char x, y;

  //keyboard info
  int keyboardfd;
  struct input_event ev;
  ssize_t keyboardBytes;

  //Open keyboard
  keyboardfd = open(keyboardDevice, O_RDONLY);
  if(keyboardfd == -1) {
    printf("ERROR Opening %s\n", keyboardDevice);
    return (PAM_AUTH_ERR);
  }
  printf("Reading input from %s\n", keyboardDevice);

  // Open Mouse
  // read only, O_RDONLY, O_WRONLY, or O_RDWR.
  mousefd = open(mouseDevice, O_RDONLY);
  if(mousefd == -1) {
    printf("ERROR Opening %s\n", mouseDevice);
    return (PAM_AUTH_ERR);
  }
  printf("Reading input from %s\n", mouseDevice);


  /*
    read() blocks i/o, causing issues with reading from both the
    keyboard and the mouse

    use poll() to block for some time to check if data is available,
    then stop blocking
   */

  // polling file descriptors array
  struct pollfd fds[2];

  fds[0].fd = mousefd;
  fds[0].events = POLLIN; // request POLLIN event, meaning there is data to read
  fds[1].fd = keyboardfd;
  fds[1].events = POLLIN;

  printf("Hangman login:\n");

  printf("Word:\n");
  for(i = 0; i < strlen(guessed); i++){
    printf("%c ", guessed[i]);
  }
  printf("\n\n");

  const int MAX_INPUTS = 100;
  int keyPresses = 0;

  while(keyPresses < MAX_INPUTS) {

    // fd array, size of array, poll time
    poll(fds, 2, 10); // 10 millisecond poll time

    // revents is a bitmask of returned events
    // returned events has POLLIN bit set, so data can be read
    if(fds[0].revents & POLLIN){

      // Read Mouse
      mouseBytes = read(mousefd, data, sizeof(data));

      // error handling
      if(mouseBytes == (ssize_t)-1){
        if(errno == EINTR)
          continue;
        else{
          fprintf(stderr, "%s.\n", strerror(errno));
          break;
        }
      } else if (mouseBytes != sizeof(data)){
        fprintf(stderr, "%s.\n", strerror(errno));
        errno= EIO;
        break;
      }


      int buttonPressed = (data[0] & 0x1 || data[0] & 0x2 || data[0] & 0x4); // checks if a mouse button has been pressed.

      if(mouseBytes > 0 && buttonPressed) {

        left = data[0] & 0x1;
        right = (data[0] & 0x2) > 0;
        middle = (data[0] & 0x4) > 0;

        /* printf("x=%d, y=%d, left=%d, middle=%d, right=%d, cnt=%d\n", x, y, left, middle, right, cnt); */
      }
    }

    if(fds[1].revents & POLLIN){ // keyboard data to read
      // Read Keyboard
      keyboardBytes = read(keyboardfd, &ev, sizeof(ev));

      // error handling
      if(keyboardBytes == (ssize_t)-1){
        if(errno == EINTR)
          continue;
        else{
          fprintf(stderr, "%s.\n", strerror(errno));
          break;
        }
      } else if (keyboardBytes != sizeof(ev)){
        errno = EIO;
        fprintf(stderr, "%s.\n", strerror(errno));
        break;
      }

      if(keyboardBytes > 0){
        /* if (ev.type == EV_KEY && ev.value >= 0 && ev.value <= 2) */
        /*   printf("%s 0x%04x (%d)\n", evval[ev.value], (int)ev.code, (int)ev.code); */

        if(ev.type == EV_KEY && ev.value == 1){
          keyPresses++;
          int isChar = 0;
          char c;

          // check to see if it is character
          for(i = 0; i < 26; i++){
            if(ev.code == charKeycodes[i]){
              isChar = 1;
              c = (char) i + 'a';
            }
          }

          if(isChar == 1){ // is a character
            // search for c in the word
            int cnt = 0;
            for(i = 0; i < strlen(word); i++){
              if(c == word[i]){
                cnt++;
                guessed[i] = c;
              }
            }

            printf("\nWord:\n");
            for(i = 0; i < strlen(guessed); i++){
              printf("%c ", guessed[i]);
            }
            printf("\n\n\n");

            if(cnt == 0){
              wrong++;
              printf("NO!\nGuesses left: %d\n\n", MAX_WRONG - wrong);
            } else if(strcmp(word, guessed) == 0){
              break;
            }

            if(wrong == MAX_WRONG){
              break;
            }
          }
        }
      }
    }
  }

  // catch remaining events;
  if(fds[0].revents & POLLIN){ // mouse data to read
    read(mousefd, data, sizeof(data));
  }
  if(fds[1].revents & POLLIN){ // keyboard data to read
    read(keyboardfd, &ev, sizeof(ev));
  }

  if(strcmp(word, guessed) == 0){
    printf("Right\n");
    return (PAM_SUCCESS);
  }

  printf("WRONG\n");
  return (PAM_AUTH_ERR);
}

PAM_EXTERN int
pam_sm_setcred(pam_handle_t *pamh, int flags,
               int argc, const char *argv[])
{

  (void)pamh;
  (void)flags;
  (void)argc;
  (void)argv;
  return (PAM_SUCCESS);
}

PAM_EXTERN int
pam_sm_acct_mgmt(pam_handle_t *pamh, int flags,
                 int argc, const char *argv[])
{

  (void)pamh;
  (void)flags;
  (void)argc;
  (void)argv;
  return (PAM_SUCCESS);
}

PAM_EXTERN int
pam_sm_open_session(pam_handle_t *pamh, int flags,
                    int argc, const char *argv[])
{

  (void)pamh;
  (void)flags;
  (void)argc;
  (void)argv;
  return (PAM_SUCCESS);
}

PAM_EXTERN int
pam_sm_close_session(pam_handle_t *pamh, int flags,
                     int argc, const char *argv[])
{

  (void)pamh;
  (void)flags;
  (void)argc;
  (void)argv;
  return (PAM_SUCCESS);
}

PAM_EXTERN int
pam_sm_chauthtok(pam_handle_t *pamh, int flags,
                 int argc, const char *argv[])
{

  (void)pamh;
  (void)flags;
  (void)argc;
  (void)argv;
  return (PAM_SUCCESS);
}
