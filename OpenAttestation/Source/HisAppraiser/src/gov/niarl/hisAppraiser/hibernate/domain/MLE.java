package gov.niarl.hisAppraiser.hibernate.domain;


import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.util.Set;

@XmlRootElement
public class MLE {

	private Long MLEID;
	private String Name;
	private String Version;
	private OEM oem;
	private OS os;
	private String Attestation_Type;
	private String MLE_Type;
	private String Description;
	
	public Long getMLEID() {
		return MLEID;
	}
	
	public void setMLEID(Long mLEID) {
		MLEID = mLEID;
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
	
	public OEM getOem() {
		return oem;
	}
	
	public void setOem(OEM oem) {
		this.oem = oem;
	}
	
	public OS getOs() {
		return os;
	}
	
	public void setOs(OS os) {
		this.os = os;
	}
	
	public String getAttestation_Type() {
		return Attestation_Type;
	}
	
	@XmlElement(name = "Attestation_Type")
	public void setAttestation_Type(String attestation_Type) {
		Attestation_Type = attestation_Type;
	}
	
	public String getMLE_Type() {
		return MLE_Type;
	}
	
	@XmlElement(name = "MLE_Type")
	public void setMLE_Type(String mLE_Type) {
		MLE_Type = mLE_Type;
	}
	
	public String getDescription() {
		return Description;
	}
	@XmlElement(name = "Description")
	public void setDescription(String description) {
		Description = description;
	}
}
