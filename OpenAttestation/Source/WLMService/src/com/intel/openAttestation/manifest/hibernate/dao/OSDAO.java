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

import com.intel.openAttestation.manifest.hibernate.domain.OS;
import com.intel.openAttestation.manifest.hibernate.util.HibernateUtilHis;

/**
 * This class serves as a central location for updates and queries against 
 * the OEM table
 * @author intel
 * @version OpenAttestation
 *
 */
public class OSDAO {

	/**
	 * Constructor to start a hibernate transaction in case one has not
	 * already been started 
	 */
	public OSDAO() {
	}
	
	public void addOSEntry(OS osEntry){
		try {
			HibernateUtilHis.beginTransaction();
			//OEM.setCreateTime(new Date());
			HibernateUtilHis.getSession().save(osEntry);
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
	
	public void editOSEntry(OS osEntry){
		try {
			HibernateUtilHis.beginTransaction();
			Session session = HibernateUtilHis.getSession();
			
			Query query = session.createQuery("from OS a where a.Name = :name and a.Version = :version");
			query.setString("name", osEntry.getName());
			query.setString("version", osEntry.getVersion());
			List list = query.list();
			if (list.size() < 1){
				HibernateUtilHis.rollbackTransaction();
				throw new Exception ("Object not found");
			}
			OS osOld = (OS)list.get(0);
			osOld.setDescription(osEntry.getDescription());
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
	
	public void deleteOSEntry (String osName, String osVersion){
		try {
			HibernateUtilHis.beginTransaction();
			Session session = HibernateUtilHis.getSession();
			Query query = session.createQuery("from OS a where a.Name = :name and a.Version = :version");
			query.setString("name", osName);
			query.setString("version", osVersion);
			List list = query.list();
			if (list.size() < 1){
				HibernateUtilHis.rollbackTransaction();
				throw new Exception ("Object not found");
			}
			OS osEntry = (OS)list.get(0);
			session.delete(osEntry);
			HibernateUtilHis.commitTransaction();
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}

	
	public boolean isOSExisted(String osName, String osVersion){
		boolean flag =false;
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("from OS a where a.Name = :name and a.Version = :version");
			query.setString("name", osName);
			query.setString("version", osVersion);
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
       
	public OS getOS(String Name, String Version){
		OS os =null;
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("from OS os " +
					"where os.Name = :osName and os.Version= :osVersion");
			query.setString("osName", Name);
			query.setString("osVersion", Version);
				List list = query.list();
				if (list.size() >= 1) {
					os = (OS)list.iterator().next();
				} 
				HibernateUtilHis.commitTransaction();
				return os;
			} catch (Exception e) {
				HibernateUtilHis.rollbackTransaction();
				e.printStackTrace();
				throw new RuntimeException(e);
			}finally{
				HibernateUtilHis.closeSession();
			}
	}
      	
	public boolean isRefMle(String name, String version){
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("select m from MLE m inner join m.os o where o.Name = :name and o.Version = :version");
			query.setString("name", name);
			query.setString("version", version);
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
      	
	public List<OS> getAllOSEntries(){
		try{
			HibernateUtilHis.beginTransaction();
			ArrayList<OS> OSList = new ArrayList<OS>();
			Query query = HibernateUtilHis.getSession().createQuery("from OS os");
			System.out.println("query:"+query.toString());
			List list = query.list();
			for (int i=0;i<list.size();i++){
				OSList.add((OS)list.get(i));
			}
			HibernateUtilHis.commitTransaction();
			return OSList;
		}catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}     	

}
