package gov.niarl.hisAppraiser.hibernate.domain;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class HOST_MLE {
	private Long ID;
	private HOST host;
	private MLE mle;
	
	public Long getID() {
		return ID;
	}
	public void setID(Long iD) {
		ID = iD;
	}
	public HOST getHost() {
		return host;
	}
	public void setHost(HOST host) {
		this.host = host;
	}
	public MLE getMle() {
		return mle;
	}
	public void setMle(MLE mle) {
		this.mle = mle;
	}
	
}