/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.intel.openAttestation.AttestationService.bean;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class HostBean {
	
	private Long ID;
	private String HostName;
	private String IPAddress;
	private String Port;
	private String Email;
	private String AddOn_Connection_String;
	private String Description;
	private String BIOSName;
	private String BIOSVersion;
	private String BIOSOem;
	private String VMMName;
	private String VMMVersion;
	private String VMMOSName;
	private String VMMOSVersion;
	private String Location;
	
	
	public Long getID() {
		return ID;
	}
	
	@XmlElement(name = "ID")
	public void setID(Long iD) {
		ID = iD;
	}
	
	public String getPort() {
		return Port;
	}
	
	@XmlElement(name = "Port")
	public void setPort(String port) {
		Port = port;
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
	
	public String getAddOn_Connection_String() {
		return AddOn_Connection_String;
	}
	
	@XmlElement(name = "AddOn_Connection_String")
	public void setAddOn_Connection_String(String addOn_Connection_String) {
		AddOn_Connection_String = addOn_Connection_String;
	}
	
	public String getEmail() {
		return Email;
	}
	
	@XmlElement(name = "Email")
	public void setEmail(String email) {
		Email = email;
	}
	
	public String getDescription() {
		return Description;
	}
	
	@XmlElement(name = "Description")
	public void setDescription(String description) {
		Description = description;
	}
	
	public String getBIOSName() {
		return BIOSName;
	}
	
	@XmlElement(name="BIOS_Name")
	public void setBIOSName(String bIOSName) {
		BIOSName = bIOSName;
	}
	public String getBIOSVersion() {
		return BIOSVersion;
	}
	@XmlElement(name="BIOS_Version")
	public void setBIOSVersion(String bIOSVersion) {
		BIOSVersion = bIOSVersion;
	}
	public String getBIOSOem() {
		return BIOSOem;
	}
	@XmlElement(name="BIOS_Oem")
	public void setBIOSOem(String bIOSOem) {
		BIOSOem = bIOSOem;
	}
	public String getVMMVersion() {
		return VMMVersion;
	}
	@XmlElement(name="VMM_Version")
	public void setVMMVersion(String vMMVersion) {
		VMMVersion = vMMVersion;
	}
	public String getVMMOSName() {
		return VMMOSName;
	}
	@XmlElement(name="VMM_OSName")
	public void setVMMOSName(String vMMOSName) {
		VMMOSName = vMMOSName;
	}
	public String getVMMOSVersion() {
		return VMMOSVersion;
	}
	@XmlElement(name="VMM_OSVersion")
	public void setVMMOSVersion(String vMMOSVersion) {
		VMMOSVersion = vMMOSVersion;
	}
	public String getVMMName() {
		return VMMName;
	}
	@XmlElement(name="VMM_Name")
	public void setVMMName(String vMMName) {
		VMMName = vMMName;
	}

	public String getLocation() {
		return Location;
	}
	@XmlElement(name="Location")
	public void setLocation(String location) {
		Location = location;
	}

	
}