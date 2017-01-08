package com.intel.openAttestation.manifest.hibernate.domain;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement

public class PcrWhiteList {
	
	private Long PcrWhiteListID;
	private String pcrName; 
	private String pcrDigest;
	private MLE mle; 
	
	public Long getPcrWhiteListID() {
		return PcrWhiteListID;
	}
	
	public void setPcrWhiteListID(Long pcrWhiteListID) {
		PcrWhiteListID = pcrWhiteListID;
	}
	
	public String getPcrName() {
		return pcrName;
	}
	
	public void setPcrName(String pcrName) {
		this.pcrName = pcrName;
	}
	
	public String getPcrDigest() {
		return pcrDigest;
	}
	
	public void setPcrDigest(String pcrDigest) {
		this.pcrDigest = pcrDigest;
	}

	public MLE getMle() {
		return mle;
	}

	public void setMle(MLE mle) {
		this.mle = mle;
	}
	
}
