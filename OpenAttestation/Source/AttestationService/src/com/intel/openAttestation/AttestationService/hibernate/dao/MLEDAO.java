/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.intel.openAttestation.AttestationService.hibernate.dao;

import gov.niarl.hisAppraiser.hibernate.domain.MLE;
import java.util.List;
import org.hibernate.Query;
import com.intel.openAttestation.AttestationService.bean.HostBean;
import com.intel.openAttestation.AttestationService.hibernate.util.HibernateUtilHis;

/**
 * This class serves as a central location for updates and queries against 
 * the OEM table
 * @author Lijuan
 * @version OpenAttestation
 *
 */
public class MLEDAO {

	/**
	 * Constructor to start a hibernate transaction in case one has not
	 * already been started 
	 */
	public MLEDAO() {
	}
	
	//"BIOS_Name":"EPSD","BIOS_Version":"55","BIOS_Oem":"EPSD","VMM_Name":"Xen","VMM_Version":"4.1.1","VMM_OSName":"RHEL","VMM_OSVersion":"6.1"
	public MLE getMLE(HostBean hostFullObj, int order){
		MLE mle=null;;
		String[] queryString = new String[2];
		try{
			HibernateUtilHis.beginTransaction();
			queryString[0]="select m from MLE m inner join m.oem o where m.Name=:biosName and m.Version=:biosVersion and o.Name =:oemName";//query BIOS information
			queryString[1]="select m from MLE m inner join m.os o where m.Name=:VMMName and m.Version=:VMMVersion and o.Name=:osName and o.Version=:osVersion";//query VMM information
			Query query = HibernateUtilHis.getSession().createQuery(queryString[order]);
			if(order == 0){
				if (hostFullObj.getBIOSName() != null){
					query.setString("biosName", hostFullObj.getBIOSName());
				} else {
					System.out.println("BIOS name is null");
				}
				if (hostFullObj.getBIOSVersion() != null){
					query.setString("biosVersion", hostFullObj.getBIOSVersion());
				} else {
					System.out.println("BIOS version is null");
				}
				if (hostFullObj.getBIOSOem() !=null){
					query.setString("oemName", hostFullObj.getBIOSOem());
				} else {
					System.out.println("OEM is null");
				}
			}
			else if(order ==1){
				if (hostFullObj.getVMMName() != null){
					query.setString("VMMName", hostFullObj.getVMMName());
				} else {
					System.out.println("VMM name is null");
				}
				if (hostFullObj.getVMMVersion() != null){
					query.setString("VMMVersion", hostFullObj.getVMMVersion());
				} else {
					System.out.println("VMM version is null");
				}
				if (hostFullObj.getVMMOSName() != null){
					query.setString("osName", hostFullObj.getVMMOSName());
				} else {
					System.out.println("VMM OS name is null");
				}
				if (hostFullObj.getVMMOSVersion() != null){
					query.setString("osVersion", hostFullObj.getVMMOSVersion());
				} else {
					System.out.println("VMM OS version is null");
				}

			}		
			List list = query.list();
			if(list.size()>0)
				mle= (MLE)list.iterator().next();
			HibernateUtilHis.commitTransaction();
			return mle;
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
	}
	
	public void updateMle(MLE mle) {
		try {
			HibernateUtilHis.beginTransaction();
			HibernateUtilHis.getSession().update(mle);
			HibernateUtilHis.commitTransaction();
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}

		
	}

}
