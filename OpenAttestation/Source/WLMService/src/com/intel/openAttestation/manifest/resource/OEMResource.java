/*
Copyright (c) 2012, Intel Corporation
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.intel.openAttestation.manifest.resource;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;

import gov.niarl.hisAppraiser.util.HisUtil;

import com.intel.openAttestation.manifest.bean.OpenAttestationResponseFault;
import com.intel.openAttestation.manifest.hibernate.dao.OEMDAO;
import com.intel.openAttestation.manifest.hibernate.domain.OEM;
import com.intel.openAttestation.manifest.resource.OEMResource;

/**
 * RESTful web service interface to work with OEM DB.
 * @author xmei1
 *
 */

@Path("resources/oem")
public class OEMResource {
	
	
	@POST
	@Consumes("application/json")
	@Produces("application/json")
	public Response addOEM(@Context UriInfo uriInfo, OEM oem,
			@Context javax.servlet.http.HttpServletRequest request){
		System.out.println("Check if the OEM Name exists:" + oem.getName());
        UriBuilder b = uriInfo.getBaseUriBuilder();
        b = b.path(OEMResource.class);
		Response.Status status = Response.Status.OK;
		boolean isValidKey = true;
        try{
			OEMDAO dao = new OEMDAO();
			
			HashMap parameters = new HashMap();
			if (oem.getName()!=null){
				parameters.put(oem.getName(), 50);
			} else {
				isValidKey = false;
			}
			
			if (oem.getDescription()!=null){
				parameters.put(oem.getDescription(), 100);
			}

			if (!isValidKey || oem.getName().length() < 1 || !HisUtil.validParas(parameters)){
				status = Response.Status.INTERNAL_SERVER_ERROR;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
						OpenAttestationResponseFault.FaultCode.FAULT_500);
				fault.setError_message("Add OEM entry failed, please check the length for each parameters" +
						" and remove all of the unwanted characters belonged to [# & + : \" \']");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			System.out.println("Check if the OEM Name exists:" + oem.getName());
			if (dao.isOEMExisted(oem.getName())){
				status = Response.Status.BAD_REQUEST;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(1006);
				fault.setError_message("Data Error - OEM " + oem.getName()+" already exists in the database");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			
			dao.addOEMEntry(oem);
	        return Response.status(status).header("Location", b.build()).type(MediaType.TEXT_PLAIN).entity("True")
	        		.build();
		}catch (Exception e){
			status = Response.Status.INTERNAL_SERVER_ERROR;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_500);
			fault.setError_message("Add OEM entry failed." + "Exception:" + e.getMessage());
			return Response.status(status).header("Location", b.build()).entity(fault)
					.build();
		}

	}

	@PUT
	@Consumes("application/json")
	@Produces("application/json")
	public Response editOEM(@Context UriInfo uriInfo, OEM oem,
			@Context javax.servlet.http.HttpServletRequest request){
        UriBuilder b = uriInfo.getBaseUriBuilder();
        b = b.path(OEMResource.class);
		Response.Status status = Response.Status.OK;
		boolean isValidKey = true;
        try{
			OEMDAO dao = new OEMDAO();
			System.out.println("Check if the OEM Name exists:" + oem.getName());
			
			HashMap parameters = new HashMap();			
			if (oem.getDescription()!=null){
				parameters.put(oem.getDescription(), 100);
			}
			
			if (oem.getName()!=null){
				parameters.put(oem.getName(), 100);
			} else {
				isValidKey = false;
			}
			if (!isValidKey || oem.getName().length() < 1 || !HisUtil.validParas(parameters)){
				status = Response.Status.INTERNAL_SERVER_ERROR;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
						OpenAttestationResponseFault.FaultCode.FAULT_500);
				fault.setError_message("Edit OEM entry failed, please check the length for each parameters" +
						" and remove all of the unwanted characters belonged to [# & + : \" \']");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			
			if (!dao.isOEMExisted(oem.getName())){
				status = Response.Status.BAD_REQUEST;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(1006);
				fault.setError_message("Data Error - OEM " + oem.getName()+" don't exists in the database");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			dao.editOEMEntry(oem);
	        return Response.status(status).header("Location", b.build()).type(MediaType.TEXT_PLAIN).entity("True")
	        		.build();
		}catch (Exception e){
			status = Response.Status.INTERNAL_SERVER_ERROR;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_500);
			fault.setError_message("Edit OEM entry failed." + "Exception:" + e.getMessage());
			return Response.status(status).header("Location", b.build()).entity(fault)
					.build();
		}

	}
	
	@DELETE
	@Produces("application/json")
	public Response deloemEntry(@QueryParam("Name") String Name, @Context UriInfo uriInfo){
        UriBuilder b = uriInfo.getBaseUriBuilder();
        b = b.path(OEMResource.class);
		Response.Status status = Response.Status.OK;
		boolean isValidKey = true;
		
        try{
			OEMDAO dao = new OEMDAO();
			
			HashMap parameters = new HashMap();
			if (Name !=null){
				parameters.put(Name, 50);
			} else {
				isValidKey = false;
			}
			
			if (!isValidKey || Name.length() < 1 || !HisUtil.validParas(parameters)){
				status = Response.Status.INTERNAL_SERVER_ERROR;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
						OpenAttestationResponseFault.FaultCode.FAULT_500);
				fault.setError_message("Delte OEM entry failed, please check the length for each parameters" +
						" and remove all of the unwanted characters belonged to [# & + : \" \']");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			
			System.out.println("Check if the OEM Name exists:" + Name);
			
			//check if the OEM has the reference with MLE 
			 if (dao.isRefMle(Name)) {
					status = Response.Status.BAD_REQUEST;
					OpenAttestationResponseFault fault = new OpenAttestationResponseFault(2012);
					fault.setError_message("Data Error - OEM " + Name +" reference with MLE, delete failed");
					return Response.status(status).header("Location", b.build()).entity(fault)
							.build();
			 }
			
			if (dao.isOEMExisted(Name)){
				dao.DeleteOEMEntry(Name);
				return Response.status(status).type(MediaType.TEXT_PLAIN).entity("True")
		        		.build();
			}
			
			status = Response.Status.BAD_REQUEST;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_1006);
			fault.setError_message("Data Error - OEM " + Name +" does not exist in the database");		
			return Response.status(status).entity(fault)
					.build();

		}catch (Exception e){
			status = Response.Status.INTERNAL_SERVER_ERROR;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_500);
			fault.setError_message("Delete OEM entry failed." + "Exception:" + e.getMessage()); 
			return Response.status(status).entity(fault)
					.build();

		}
	}

	@GET
	@Produces("application/json")
	public List<OEM> getOEMEntry(@QueryParam("index") String index,
			@QueryParam("CompName") String name,@QueryParam("CompDesc") String desc){
		OEMDAO dao = new OEMDAO();
		List<OEM> emptyList = new ArrayList<OEM>();
		if (index == null && name == null && desc == null)
			return dao.getAllOEMEntries();
		else if ( index != null)
			//@TODO 
			return emptyList;
		else if (name != null && desc == null)
			//@TODO 
			return emptyList;
		else if (name == null && desc != null)
			//@TODO 
			return emptyList;
		else
			//@TODO 
			return emptyList;
	}

}
