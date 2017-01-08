package com.intel.openAttestation.manifest.bean;

import javax.xml.bind.annotation.XmlElement;

public class MLE_Manifest {

	private String Name;
	private String Value;
	public String getName() {
		return Name;
	}
	@XmlElement(name="Name")
	public void setName(String name) {
		Name = name;
	}
	public String getValue() {
		return Value;
	}
	
	@XmlElement(name="Value")
	public void setValue(String value) {
		Value = value;
	}
	
	
}
