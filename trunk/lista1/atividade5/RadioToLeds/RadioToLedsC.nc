/*
 * "Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * @author Prabal Dutta
 *
 */

#include "RadioToLeds.h"

module RadioToLedsC {
  uses interface Boot;
  uses interface Leds;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}

implementation {
  uint16_t data;

  task void setLeds() {
    if (data > 700)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (data > 500)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (data > 300)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) { call AMControl.start(); }
  }

  event void AMControl.stopDone(error_t err) { }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(Msg)) {
      Msg* localpkt = (Msg*)payload;
    //  if (post setLeds() == SUCCESS) {
         data = localpkt->data;
	 post setLeds();
     // }
    }
    return msg;
  }
}
