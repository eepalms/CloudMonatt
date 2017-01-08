/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package gov.niarl.hisAppraiser.hibernate.domain;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Java class linked to the PCR_manifest table.
 * @author  intel
 * @version OpenAttestation
 *
 */

@XmlRootElement

public class OS {
	Long ID;
    String Name;
    String Version;
    String Description;
    
	public OS(){}
        
    public OS(Long ID, String name, String version, String desc){
    	this.Name = name;
    	this.Version = version;
    	this.Description = desc;
    }
    
	public Long getID() {
		return ID;
	}

	public void setID(Long id) {
		ID = id;
	}
	
	public String getName() {
		return Name;
	}
	
	@XmlElement(name = "Name")
	public void setName(String name) {
		Name = name;
	}
	
	public String getVersion() {
		return Version;
	}
	
	@XmlElement(name = "Version")
	public void setVersion(String version) {
		Version = version;
	}
	
	public String getDescription() {
		return Description;
	}

	@XmlElement(name = "Description")
	public void setDescription(String desc) {
		Description = desc;
	}

	/**
     * validate 
     * @return
     */
	public String validateDataFormat(){
    	return "";
    }
}
