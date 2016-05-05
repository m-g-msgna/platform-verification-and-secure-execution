/*******************************************************/
/*!
    \file        AES.h
    \brief       Header of Assembler AES implementation
    \version     1.0
*/
/*******************************************************/

#ifndef AES
#define AES

/** INCLUDES */
#include "global.h"

/** Encrypts one AES block in ECB mode (Assembler function).

 The first parameter is the state of the assembler routine. When the function is called,
 it must contain the plaintext. after the function finishes, it will contain the ciphertext

 The second parameter is used to pass the key.

 \param[in] the first parameter is used to pass the plaintexr to the assembler. It will be overwritten with the ciphertext
 \param[out] the first parameter will contain the ciphertext after the execution of the function
 \param[in] the second parameter is used to pass the scheduled key to the assembler. It will NOT be overwritten
 */
void AES_enc (
    unsigned char *,
    unsigned char *,
    unsigned char *);


/** Decrypts one AES block in ECB mode (Assembler function).

 The first parameter is the state of the assembler routine. When the function is called,
 it must contain the plaintext. after the function finishes, it will contain the ciphertext

 The second parameter is used to pass the key.

 \param[in] the first parameter is used to pass the ciphertext to the assembler. It will be overwritten with the ciphertext
 \param[out] the first parameter will contain the plaintext after the execution of the function
 \param[in] the second parameter is used to pass the scheduled key to the assembler. It will NOT be overwritten
 \param[in] the third parameter is empty SRAM space. It will be overwritten
 */
void AES_dec (
    unsigned char *,
    unsigned char *,
    unsigned char *);


/** Schedules one AES S-Box Keys and Round Keys  (Assembler function).

 The first parameter is the state of the assembler routine. When the function is called,
 it must contain the key. after the function finishes, it will contain the key as well

 The second parameter is used to pass the key.

 \param[in] the first parameter is used to pass the key to the assembler. It will NOT be overwritten.
 \param[out] the second parameter will contain the s-box key and round keys after the execution of the function
 \param[in] the third parameter is empty SRAM space. It will be overwritten
 */
void schedule_key (
    unsigned char *,
    unsigned char *,
    unsigned char *);

#endif
