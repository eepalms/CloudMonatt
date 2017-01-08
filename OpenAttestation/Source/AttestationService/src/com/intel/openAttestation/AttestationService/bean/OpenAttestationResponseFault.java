/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source error_code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.intel.openAttestation.AttestationService.bean;

import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement
public class OpenAttestationResponseFault {
	private int error_code;
	private String error_message;
	private String detail;
	
	public OpenAttestationResponseFault(){}
	
	public OpenAttestationResponseFault (int error_code){
		this.error_code= error_code;
		}

	
	public int getError_code() {
		return error_code;
	}
	public void setError_code(int code) {
		this.error_code = code;
	}

	public String getError_message() {
		return error_message;
	}
	public void setError_message(String message) {
		this.error_message = message;
	}
	
	public String getDetail() {
		return detail;
	}

	public void setDetail(String detail) {
		this.detail = detail;
	}

	public static class FaultCode{
		public static int FAULT_1006 = 1006;
		public static int FAULT_401 = 401;
		public static int FAULT_404 = 404;
		public static int FAULT_500 = 500;
		public static int FAULT_2001 = 2001;
		public static int FAULT_412 = 412;
		public static int FAULT_2000 = 2000;
	}


}
