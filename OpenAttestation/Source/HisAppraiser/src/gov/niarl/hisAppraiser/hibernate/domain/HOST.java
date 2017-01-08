package gov.niarl.hisAppraiser.hibernate.domain;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

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