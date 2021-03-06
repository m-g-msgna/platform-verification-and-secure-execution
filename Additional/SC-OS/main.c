/**********************************************/
/*! 
    \file        main.c
    \brief       Basic smart card OS supporting the T=1 protocol  
    \version     1.0

*/
/**********************************************/

#include "global.h"
#include "functions.h"
#include "T1_layer.h"

/*
** Main OS routine calling all subfunctions. After sending the ATR it waits
** for incoming APDUs, which will then be processed by subfunctions
*/
int main (void)
{

  unsigned char result, cnt;

  command_APDU rec_APDU;        /* struct for command APDU */
  command_APDU *p_rec_APDU;     /* pointer to a command APDU */
  response_APDU res_APDU;       /* struct for response APDU */
  response_APDU *p_res_APDU;    /* pointer to a command APDU */

  p_rec_APDU = &rec_APDU;
  p_res_APDU = &res_APDU;


  for (cnt = 0; cnt < 50; cnt++) {
  }; /* wait before transmitting ATR (at least 400 cycles) */

  transmit_ATR ();              /* transmit the Answer to Reset */


  /* endless loop to receive and process commands */
  for (;;) {
    result = receive_APDU (p_rec_APDU);    /* receive APDU according to T=1 */

    if (result != OK) {            /* check for EDC checksum error */
      (*p_res_APDU).NAD = rec_APDU.NAD;
      (*p_res_APDU).PCB = rec_APDU.PCB;
      (*p_res_APDU).LEN = 2;
      (*p_res_APDU).LE = 0;
      (*p_res_APDU).SW1 = 0x67;    /* checksum error */
      (*p_res_APDU).SW2 = 0x00;
    }
    else {
      command_Handler (p_rec_APDU, p_res_APDU);    /* Call command handler  */
    }
    send_APDU (p_res_APDU);        /* transmit response APDU according to T=1 */

    /* Reset response and receive APDU */
    (*p_res_APDU).NAD = 0x00;
    (*p_res_APDU).PCB = 0x00;
    (*p_res_APDU).LEN = 2;
    (*p_res_APDU).LE = 0;
    (*p_res_APDU).SW1 = 0x64;    /* error w/o changing EEPROM */
    (*p_res_APDU).SW2 = 0x00;

    (*p_rec_APDU).NAD = 0x00;
    (*p_rec_APDU).PCB = 0x00;
    (*p_rec_APDU).LEN = 0;
    (*p_rec_APDU).LE = 0;
    (*p_rec_APDU).LC = 0;
    (*p_rec_APDU).CLA = 0x00;
    (*p_rec_APDU).INS = 0x00;
  }
}
