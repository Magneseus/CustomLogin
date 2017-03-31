/*
  currently this is pam_permit
 */

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <string.h>
#include <fcntl.h>

#include <security/pam_modules.h>

PAM_EXTERN int
pam_sm_authenticate(pam_handle_t *pamh, int flags,
                    int argc, const char *argv[])
{
  /*
    this needs to be filled in.

    how will we get mouse input?
  */

  int fd, bytes;
  unsigned char data[3];

  const char *pDevice = "/dev/input/mice";

  // Open Mouse
  fd = open(pDevice, O_RDWR);
  if(fd == -1) {
    /* printf("ERROR Opening %s\n", pDevice); */
    return (PAM_AUTH_ERR);
  }

  /* struct pam_message msg; */
  /* const struct pam_message *msgp; */

  int password[3] = {1, 1, 2}; //left, left, right
  int sequence[100];

  int left=0, middle=0, right = 0;
  signed char x, y;
  int cnt = 0;
  while(cnt < 100
        && right == 0
        )
    {
      // Read Mouse
      bytes = read(fd, data, sizeof(data));

      if(bytes > 0
         && (data[0] & 0x1 || data[0] & 0x2 || data[0] & 0x4)
         )
        {
          /* printf("data[0]: %d\n", data[0]); */
          left = data[0] & 0x1;
          right = data[0] & 0x2;
          middle = data[0] & 0x4;

          sequence[cnt] = data[0] & 7;

          x = data[1];
          y = data[2];
          printf("x=%d, y=%d, left=%d, middle=%d, right=%d, cnt=%d\n", x, y, left, middle, right, cnt);
          cnt++;
        }
    }

  bytes = read(fd, data, sizeof(data));

  if(cnt == 3){
    for(int i = 0; i < 3; i++){
      printf("%d %d\n", password[i], sequence[i]);
      if(password[i] != sequence[i]){
        printf("WRONG\n");
        return (PAM_AUTH_ERR);
      }
    }
    printf("RIGHT\n");
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

#ifdef PAM_MODULE_ENTRY
PAM_MODULE_ENTRY("custom_login");
#endif
