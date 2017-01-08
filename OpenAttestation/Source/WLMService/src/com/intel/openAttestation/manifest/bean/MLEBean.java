package com.intel.openAttestation.manifest.bean;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class MLEBean {

	private String Name;
	private String Version;
	private String OsName;
	private String OsVersion;
	private String OemName;
	private String OemDescription;
	private String Attestation_Type;
	private String MLE_Type;
	private String Description;
	private List<MLE_Manifest> MLE_Manifests;
	
	public String getName() {
		return Name;
	}
	@XmlElement(name="Name")
	public void setName(String name) {
		Name = name;
	}
	public String getVersion() {
		return Version;
	}
	@XmlElement(name="Version")
	public void setVersion(String version) {
		Version = version;
	}
	public String getOsName() {
		return OsName;
	}
	
	@XmlElement(name="OsName")
	public void setOsName(String osName) {
		OsName = osName;
	}
	public String getOsVersion() {
		return OsVersion;
	}
	
	@XmlElement(name="OsVersion")
	public void setOsVersion(String osVersion) {
		OsVersion = osVersion;
	}
	public String getOemName() {
		return OemName;
	}
	
	@XmlElement(name="OemName")
	public void setOemName(String oemName) {
		OemName = oemName;
	}
	public String getOemDescription() {
		return OemDescription;
	}
	
	@XmlElement(name="OemDescription")
	public void setOemDescription(String oemDescription) {
		OemDescription = oemDescription;
	}
	public String getAttestation_Type() {
		return Attestation_Type;
	}
	
	@XmlElement(name="Attestation_Type")
	public void setAttestation_Type(String attestation_Type) {
		Attestation_Type = attestation_Type;
	}
	
	public String getMLE_Type() {
		return MLE_Type;
	}
	
	@XmlElement(name="MLE_Type")
	public void setMLE_Type(String mLE_Type) {
		MLE_Type = mLE_Type;
	}
	
	public String getDescription() {
		return Description;
	}
	
	@XmlElement(name="Description")
	public void setDescription(String description) {
		Description = description;
	}
	
	public List<MLE_Manifest> getMLE_Manifests() {
		return MLE_Manifests;
	}
	
	@XmlElement(name="MLE_Manifests")
	public void setMLE_Manifests(List<MLE_Manifest> mLE_Manifests) {
		MLE_Manifests = mLE_Manifests;
	}
	
}
