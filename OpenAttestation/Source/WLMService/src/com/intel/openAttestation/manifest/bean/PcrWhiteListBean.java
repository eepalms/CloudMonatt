package com.intel.openAttestation.manifest.bean;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement


public class PcrWhiteListBean {
	
	private String pcrName; 
	public String getPcrName() {
		return pcrName;
	}
	@XmlElement(name = "pcrName")
	public void setPcrName(String pcrName) {
		this.pcrName = pcrName;
	}
	public String getPcrDigest() {
		return pcrDigest;
	}
	@XmlElement(name = "pcrDigest")
	public void setPcrDigest(String pcrDigest) {
		this.pcrDigest = pcrDigest;
	}
	public String getMLEName() {
		return MLEName;
	}
	@XmlElement(name = "mleName")
	public void setMLEName(String mLEName) {
		MLEName = mLEName;
	}
	public String getMLEVersion() {
		return MLEVersion;
	}
	@XmlElement(name = "mleVersion")
	public void setMLEVersion(String mLEVersion) {
		MLEVersion = mLEVersion;
	}
	public String getOEMName() {
		return OEMName;
	}
	@XmlElement(name = "oemName")
	public void setOEMName(String oEMName) {
		OEMName = oEMName;
	}
	public String getOSName() {
		return OSName;
	}
	@XmlElement(name = "osName")
	public void setOSName(String oSName) {
		OSName = oSName;
	}
	public String getOSVersion() {
		return OSVersion;
	}
	@XmlElement(name = "osVersion")
	public void setOSVersion(String oSVersion) {
		OSVersion = oSVersion;
	}
	private String pcrDigest;
	private String MLEName;
	private String MLEVersion;
	private String OEMName;
	private String OSName;
	private String OSVersion;
	
	
}
