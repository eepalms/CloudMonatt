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

public class TxtLog {

	private Long id;
	
	private MeasureLog measureLog;
	
	private String osSinitDataCapabilities;
	
	private Integer version;
	
	private String sinitHash;
	
	private String edxSenterFlags;
	
	private String biosAcmId;
	
	private String msegValid;
	
	private String stmHash;
	
	private String policyControl;
	
	private String lcpPolicyHash;
	
	private String processorScrTmStatus;
	
	private String mleHash;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public MeasureLog getMeasureLog() {
		return measureLog;
	}

	public void setMeasureLog(MeasureLog measureLog) {
		this.measureLog = measureLog;
	}

	public String getOsSinitDataCapabilities() {
		return osSinitDataCapabilities;
	}

	public void setOsSinitDataCapabilities(String osSinitDataCapabilities) {
		this.osSinitDataCapabilities = osSinitDataCapabilities;
	}

	public Integer getVersion() {
		return version;
	}

	public void setVersion(Integer version) {
		this.version = version;
	}

	public String getSinitHash() {
		return sinitHash;
	}

	public void setSinitHash(String sinitHash) {
		this.sinitHash = sinitHash;
	}

	public String getEdxSenterFlags() {
		return edxSenterFlags;
	}

	public void setEdxSenterFlags(String edxSenterFlags) {
		this.edxSenterFlags = edxSenterFlags;
	}

	public String getBiosAcmId() {
		return biosAcmId;
	}

	public void setBiosAcmId(String biosAcmId) {
		this.biosAcmId = biosAcmId;
	}

	public String getMsegValid() {
		return msegValid;
	}

	public void setMsegValid(String msegValid) {
		this.msegValid = msegValid;
	}

	public String getStmHash() {
		return stmHash;
	}

	public void setStmHash(String stmHash) {
		this.stmHash = stmHash;
	}

	public String getPolicyControl() {
		return policyControl;
	}

	public void setPolicyControl(String policyControl) {
		this.policyControl = policyControl;
	}

	public String getLcpPolicyHash() {
		return lcpPolicyHash;
	}

	public void setLcpPolicyHash(String lcpPolicyHash) {
		this.lcpPolicyHash = lcpPolicyHash;
	}

	public String getProcessorScrTmStatus() {
		return processorScrTmStatus;
	}

	public void setProcessorScrTmStatus(String processorScrTmStatus) {
		this.processorScrTmStatus = processorScrTmStatus;
	}

	public String getMleHash() {
		return mleHash;
	}

	public void setMleHash(String mleHash) {
		this.mleHash = mleHash;
	}
	
	
	
	
}
