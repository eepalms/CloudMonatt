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

import com.intel.openAttestation.manifest.hibernate.domain.MLE;
import com.intel.openAttestation.manifest.hibernate.domain.PcrWhiteList;
import com.intel.openAttestation.manifest.hibernate.util.HibernateUtilHis;

/**
 * This class serves as a central location for updates and queries against 
 * the OEM table
 * @author intel
 * @version OpenAttestation
 *
 */
public class PcrWhiteListDAO {

	/**
	 * Constructor to start a hibernate transaction in case one has not
	 * already been started 
	 */
	public PcrWhiteListDAO() {
	}
	
	public void addPcrEntry(PcrWhiteList pcrEntry){
		try {
			HibernateUtilHis.beginTransaction();
			//OEM.setCreateTime(new Date());
			HibernateUtilHis.getSession().save(pcrEntry);
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
	
	public void editPcrEntry (PcrWhiteList pcrEntry){
		try {
			HibernateUtilHis.beginTransaction();
			HibernateUtilHis.getSession().saveOrUpdate(pcrEntry);
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
	
	public void deletePcrEntry (String pcrName, Long mleId){
		try {
			HibernateUtilHis.beginTransaction();
			Session session = HibernateUtilHis.getSession();
			Query query = session.createQuery("from PcrWhiteList a where a.pcrName = :name and a.mle.MLEID = :mleid");
			query.setString("name", pcrName);
			query.setLong("mleid", mleId);
			List list = query.list();
			if (list.size() < 1){
				HibernateUtilHis.rollbackTransaction();
				throw new Exception ("Object not found");
			}
			PcrWhiteList pcrEntry = (PcrWhiteList)list.get(0);
			session.delete(pcrEntry);
			HibernateUtilHis.commitTransaction();
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}
	
	public boolean isPcrExisted(String pcrName, Long mleId){
		boolean flag =false;
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("from PcrWhiteList a where a.pcrName = :name and a.mle.MLEID = :mleid");
			query.setString("name", pcrName);
			query.setLong("mleid", mleId);
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

	public PcrWhiteList queryPcrByOEMid (String Name, String Version, String OEMname, String PcrName){
		List<PcrWhiteList> pcrList = null;
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("select c from MLE a, OEM b, PcrWhiteList c where a.Name = :name and a.Version = :version and a.oem.OEMID = b.OEMID and b.Name = :oem_name and a.MLEID = c.mle.MLEID and c.pcrName = :pcr_name");
			query.setString("name", Name);
			query.setString("version", Version);
			query.setString("oem_name", OEMname);
			query.setString("pcr_name", PcrName);
			List list = query.list();
			pcrList = (List<PcrWhiteList>)list;
			if (list.size() < 1) 
			{
				HibernateUtilHis.commitTransaction();
				return null;
			} else {
				HibernateUtilHis.commitTransaction();
				return (PcrWhiteList)pcrList.get(0);
			}
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}
	
	public PcrWhiteList queryPcrByOSid (String Name, String Version, String OSname, String OSversion, String PcrName){
		List<PcrWhiteList> pcrList = null;
		try {
			HibernateUtilHis.beginTransaction();
			Query query = HibernateUtilHis.getSession().createQuery("select c from MLE a, OS b, PcrWhiteList c where a.Name = :name and a.Version = :version and a.os.ID = b.ID and b.Name = :os_name and b.Version = :os_version and a.MLEID = c.mle.MLEID and c.pcrName = :pcr_name");
			query.setString("name", Name);
			query.setString("version", Version);
			query.setString("os_name", OSname);
			query.setString("os_version", OSversion);
			query.setString("pcr_name", PcrName);
			List list = query.list();
			pcrList = (List<PcrWhiteList>)list;
			if (list.size() < 1) 
			{
				HibernateUtilHis.commitTransaction();
				return null;
			} else {
				HibernateUtilHis.commitTransaction();
				return (PcrWhiteList)pcrList.get(0);
			}
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}
		
	}

	public void deletePcrByMleID(Long mleId){
		try {
            HibernateUtilHis.beginTransaction();
            Session session = HibernateUtilHis.getSession();
            Query query = session.createQuery("from PcrWhiteList a where a.mle.MLEID = :mleid");
            query.setLong("mleid", mleId);
            List list = query.list();
            for(int i=0; i < list.size(); i++){
                 session.delete((PcrWhiteList)list.get(i));
	        }
            HibernateUtilHis.commitTransaction();
	    } catch (Exception e) {
	            HibernateUtilHis.rollbackTransaction();
	            e.printStackTrace();
	            throw new RuntimeException(e);
	    }finally{
	            HibernateUtilHis.closeSession();
	    }

	}        

    public PcrWhiteList getPcr(String pcrName, Long mleId){
        try {
        	PcrWhiteList pcr = null;
            HibernateUtilHis.beginTransaction();
                Query query = HibernateUtilHis.getSession().createQuery("from PcrWhiteList a where a.pcrName = :name and a.mle.MLEID = :mleid");
                query.setString("name", pcrName);
                query.setLong("mleid", mleId);
                List list = query.list();
                if (list.size() >= 1)
                	pcr = (PcrWhiteList)list.iterator().next();
                HibernateUtilHis.commitTransaction();
                return pcr;
                
        } catch (Exception e) {
                HibernateUtilHis.rollbackTransaction();
                e.printStackTrace();
                throw new RuntimeException(e);
        }finally{
                HibernateUtilHis.closeSession();
        }
    }
    
    public void addPcrList(List<PcrWhiteList> pcrList){
		try {
			HibernateUtilHis.beginTransaction();
			Session session = HibernateUtilHis.getSession();
			for (PcrWhiteList pcr: pcrList)
				session.save(pcr);
			HibernateUtilHis.commitTransaction();
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			e.printStackTrace();
			throw new RuntimeException(e);
		}finally{
			HibernateUtilHis.closeSession();
		}

	}
    
	public List<PcrWhiteList> queryPcrByMLEid(long mleID){
		List<PcrWhiteList> pcrList = null;
		try {
			Query query = HibernateUtilHis.getSession().createQuery("select a from PcrWhiteList a where a.mle.MLEID = :mleID");
			query.setLong("mleID", mleID);
			List<PcrWhiteList> list = query.list();
			pcrList = (List<PcrWhiteList>)list;
			if (list.size() < 1) 
			{
				return null;
			} else {
				return pcrList;
			}
		}catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		}
		
	}
	
}
