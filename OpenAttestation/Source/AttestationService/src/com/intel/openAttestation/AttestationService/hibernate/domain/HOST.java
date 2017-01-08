/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.intel.openAttestation.AttestationService.hibernate.domain;

import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlElement;

/**
 * Java class linked to the HOST table.
 * @author  intel
 * @version OpenAttestation
 *
 */

@XmlRootElement

public class HOST {
	private Long ID;
	private String HostName;
	private String IPAddress;
	private String Port;
	private String Email;
	private String AddOn_Connection_String;
	private String Description;
	public Long getID() {
		return ID;
	}
	public void setID(Long iD) {
		ID = iD;
	}
	public String getHostName() {
		return HostName;
	}
	
	@XmlElement(name = "HostName")
	public void setHostName(String hostName) {
		HostName = hostName;
	}
	public String getIPAddress() {
		return IPAddress;
	}
	
	@XmlElement(name = "IPAddress")
	public void setIPAddress(String iPAddress) {
		IPAddress = iPAddress;
	}
	public String getPort() {
		return Port;
	}
	
	@XmlElement(name = "Port")
	public void setPort(String port) {
		Port = port;
	}
	public String getEmail() {
		return Email;
	}
	
	@XmlElement(name = "Email")
	public void setEmail(String email) {
		Email = email;
	}
	public String getAddOn_Connection_String() {
		return AddOn_Connection_String;
	}
	
	@XmlElement(name = "AddOn_Connection_String")
	public void setAddOn_Connection_String(String addOn_Connection_String) {
		AddOn_Connection_String = addOn_Connection_String;
	}
	public String getDescription() {
		return Description;
	}
	
	@XmlElement(name = "Description")
	public void setDescription(String description) {
		Description = description;
	}
	

	
}
