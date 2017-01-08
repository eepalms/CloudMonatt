/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package gov.niarl.hisAppraiser.hibernate.dao;

import gov.niarl.hisAppraiser.hibernate.domain.AuditLog;
import gov.niarl.hisAppraiser.hibernate.domain.MeasureLog;
import gov.niarl.hisAppraiser.hibernate.domain.Module;
import gov.niarl.hisAppraiser.hibernate.domain.SystemConstants;
import gov.niarl.hisAppraiser.hibernate.domain.TxtLog;
import gov.niarl.hisAppraiser.hibernate.util.HibernateUtilHis;
import java.util.ArrayList;
import java.util.List;
import org.hibernate.Query;

public class MeasureDao {
	
	public MeasureDao(){
		HibernateUtilHis.beginTransaction();
	}
	/**
	 * This saves an MeasureLog 
	 * @param measureLog MeasureLog entry to save
	 */
	public void saveMeasureLog(MeasureLog measureLog, TxtLog txtLog, List<Module> modules) {
		try {
			//save measureLog
			HibernateUtilHis.getSession().save(measureLog);
			
			//save txtLogs
			if (measureLog.getTxtStatus() == 1 || measureLog.getTxtStatus() ==2){
				HibernateUtilHis.getSession().save(txtLog);
			}
			
			//save modules
			if (modules.size() > 0){
				for (Module module: modules){
					HibernateUtilHis.getSession().save(module);
				}
			}
		} catch (Exception e) {
			HibernateUtilHis.rollbackTransaction();
			throw new RuntimeException(e);
		}
		
	}
	
	public List<String> getModuleNamesByMeasureLog(MeasureLog measureLog){
		Query query = HibernateUtilHis.getSession().createQuery("select distinct m.moduleName from Module m where m.measureLog = :measureLog");
		query.setEntity("measureLog", measureLog);
		List<String> list = query.list();
		if (list.size() < 1) {
			return  new ArrayList<String>();
		} else {
			return (List<String>) list;
		}
	}
	
	public List<String> getModuleNames(){
		Query query = HibernateUtilHis.getSession().createQuery("select distinct m.moduleName from Module m");
		List<String> list = query.list();
		if (list.size() < 1) {
			return  new ArrayList<String>();
		} else {
			return (List<String>) list;
		}
	}
	
}
