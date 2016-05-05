/***************************************************/
/*!
    \file        functions.h
    \brief       Implemented functions of the OS
    \version     1.0
*/
/***************************************************/

#ifndef OS_functions
#define OS_functions

#include "global.h"

/** Encrypts one AES block in ECB mode.

 The key must be initialized prior to calling this function.
 The answer length depends on the LE byte of the command.

 \param[in] com_APDU pointer to received command APDU containing the plaintext and the expected answer length
 \param[out] resp_APDU pointer to new response APDU to which the expected number of ciphertext bytes is written
 */

void do_AES_encrypt(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

/** Decrypts one AES block in ECB mode.

 The key must be initialized prior to calling this function.
 The answer length depends on the LE byte of the command.

 \param[in] com_APDU pointer to received command APDU containing the ciphertext and the expected answer length
 \param[out] resp_APDU pointer to new response APDU to which the expected number of plaintext bytes is written
 */

void do_AES_decrypt(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

/** Sets the key for the AES encryption.

 The key must be initialized prior to calling the do_AES_encrypt function.

 \param[in] com_APDU pointer to received command APDU containing the key
 \param[out] resp_APDU pointer to new response APDU which only consists of an error code (trailer)
 */

void do_set_key(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

/** Internal OS routine for calling the implemented functions

 The command handler checks the class (CLA) byte and finds and calls the corresponding function
 for the instruction (INS) byte. If one of the parameters is wrong or not set, it returns an APDU
 with the appropiate error code

 \param[in] com_APDU pointer to received command APDU to be processed
 \param[out] resp_APDU pointer to response APDU with processed data or appropiate error code
 */
void command_Handler(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

#endif
