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
 * @author: Prabal Dutta
 * @author: Jan Hauer
 * Based on tutorials/BlinkToRadioAppC.nc and SenseAppC.c applications.
 *
 */

#include <Timer.h>
#include "SenseToRadio.h"

module SenseToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli>;
  uses interface Read<uint16_t>;
  uses interface Packet;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
}

implementation {
  message_t packet;
  bool busy = FALSE;

  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) 
      call Timer.startPeriodic(500);
    else 
      call AMControl.start();
  }

  event void AMControl.stopDone(error_t err) { }

  event void Timer.fired() {
    call Read.read();
  }
 
  event void Read.readDone(error_t result, uint16_t data) {
    if (!busy) {
      Msg* localpkt = (Msg*) (call Packet.getPayload(&packet, sizeof(Msg)));
      if (localpkt == NULL) { return; }
      localpkt->data = data;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(Msg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&packet == msg) {
      busy = FALSE;
      call Leds.led1Toggle();
    }
  }
}
