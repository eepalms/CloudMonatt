/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.intel.openAttestation.manifest.hibernate.dao;

import java.util.ArrayList;
import java.util.List;
import org.hibernate.Query;
import org.hibernate.Session;
import com.intel.openAttestation.manifest.hibernate.domain.OEM;
import com.intel.openAttestation.manifest.hibernate.util.HibernateUtilHis;

/**
 * This class serves as a central location for updates and queries against 
 * the OEM table
 * @author intel
 * @version OpenAttestation
 *
 */
public class OEMDAO {

	/**
	 * Constructor to start a hibernate transaction in case one has not
	 * already been started 
	 */
	public OEMDAO() {
	}
	
	public OEM addOEMEntry(OEM OEMEntry){
		try {
			HibernateUtilHis.beginTransaction();
			//OEM.setCreateTime(new Date());
			HibernateUtilHis.getSession().save(OEMEntry);
			HibernateUtilHis.commitTransaction();
			return OEMEntry;
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}

	}
	
	public void editOEMEntry (OEM oemEntry){
		try {
			HibernateUtilHis.beginTransaction();
			Session session = HibernateUtilHis.getSession();
			
			Query query = session.createQuery("from OEM a where a.Name = :name");
			query.setString("name", oemEntry.getName());
			List list = query.list();
			if (list.size() < 1){
				HibernateUtilHis.rollbackTransaction();
				throw new Exception ("Object not found");
			}
			OEM oemOld = (OEM)list.get(0);
			oemOld.setDescription(oemEntry.getDescription());
			HibernateUtilHis.commitTransaction();
			//return oemEntry;
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}

	
	public void DeleteOEMEntry (String Name){
		try {
			HibernateUtilHis.beginTransaction();
			Session session = HibernateUtilHis.getSession();
			Query query = session.createQuery("from OEM a where a.Name = :NAME");
			query.setString("NAME", Name);
			List list = query.list();
			if (list.size() < 1){
				HibernateUtilHis.rollbackTransaction();
				throw new Exception ("Object not found");
			}
			OEM OEMEntry = (OEM)list.get(0);
			session.delete(OEMEntry);
			HibernateUtilHis.commitTransaction();
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}
	public boolean isOEMExisted(String Name){
		boolean flag =false;
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("from OEM a where a.Name = :value");
			query.setString("value", Name);
			List list = query.list();
		
			if (list.size() < 1) {
				flag =  false;
			} else {
				flag = true;
			}
			HibernateUtilHis.commitTransaction();
			return flag;
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
	}
	public OEM getOEM(String Name){
		OEM oem =null;
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("from OEM a where a.Name = :value");
			query.setString("value", Name);
			List list = query.list();
			if (list.size() >= 1) {
				oem = (OEM)list.iterator().next();
			} 
			HibernateUtilHis.commitTransaction();
			return oem;
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
	}
	
	public boolean isRefMle(String name){
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("select m from MLE m inner join m.oem o where o.Name = :name");
			query.setString("name", name);
			List list = query.list();
			if (list.size() >= 1) {
				HibernateUtilHis.commitTransaction();
				return true;
			} else {
				HibernateUtilHis.commitTransaction();
				return false;
			}
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
	}
	
	public List<OEM> getAllOEMEntries(){
		try{
			HibernateUtilHis.beginTransaction();
			ArrayList<OEM> OEMList = new ArrayList<OEM>();
			Query query = HibernateUtilHis.getSession().createQuery("from OEM oem");
			System.out.println("query:"+query.toString());
			List list = query.list();
			for (int i=0;i<list.size();i++){
				OEMList.add((OEM)list.get(i));
			}
			HibernateUtilHis.commitTransaction();
			return OEMList;
		}catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}   
}
