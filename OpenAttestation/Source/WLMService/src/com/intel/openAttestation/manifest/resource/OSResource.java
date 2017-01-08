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

import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

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
import com.intel.openAttestation.manifest.hibernate.dao.OSDAO;
import com.intel.openAttestation.manifest.hibernate.domain.OS;
import com.intel.openAttestation.manifest.resource.OSResource;

/**
 * RESTful web service interface to work with OEM DB.
 * @author xmei1
 *
 */

@Path("resources/os")
public class OSResource {
		
	@POST
	@Consumes("application/json")
	@Produces("application/json")
	public Response addOS(@Context UriInfo uriInfo, OS os, @Context javax.servlet.http.HttpServletRequest request){
        UriBuilder b = uriInfo.getBaseUriBuilder();
        b = b.path(OSResource.class);
		Response.Status status = Response.Status.OK;
		boolean isValidKey = true;
        try{
			OSDAO dao = new OSDAO();
			System.out.println("Check if the OS Name exists:" + os.getName());
			
			HashMap parameters = new HashMap();
			if (os.getName() != null){
				parameters.put(os.getName(), 50);
			} else {
				isValidKey = false;
			}
			if (os.getVersion() != null){
				parameters.put(os.getVersion(), 50);
			} else {
				isValidKey = false;
			}
			if (os.getDescription() != null){
				parameters.put(os.getDescription(), 100);
			}
			
			if ( !isValidKey  || os.getName().length() < 1 || os.getVersion().length() < 1 || !HisUtil.validParas(parameters)){
				status = Response.Status.INTERNAL_SERVER_ERROR;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
						OpenAttestationResponseFault.FaultCode.FAULT_500);
				fault.setError_message("Add OS entry failed, please check the length for each parameters" +
						" and remove all of the unwanted characters belonged to [# & + : \" \']");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			
			
			if (dao.isOSExisted(os.getName(), os.getVersion())){
				status = Response.Status.BAD_REQUEST;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(1006);
				fault.setError_message("Data Error - OS " + os.getName()+ os.getVersion() + " already exists in the database");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			
			dao.addOSEntry(os);
	        return Response.status(status).header("Location", b.build()).type(MediaType.TEXT_PLAIN).entity("True")
	        		.build();
		}catch (Exception e){
			status = Response.Status.INTERNAL_SERVER_ERROR;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_500);
			fault.setError_message("Add OS entry failed." + "Exception:" + e.getMessage());
			return Response.status(status).header("Location", b.build()).entity(fault)
					.build();
		}

	}

	@PUT
	@Consumes("application/json")
	@Produces("application/json")
	public Response editOS(@Context UriInfo uriInfo, OS os, @Context javax.servlet.http.HttpServletRequest request){
        UriBuilder b = uriInfo.getBaseUriBuilder();
        b = b.path(OSResource.class);
		Response.Status status = Response.Status.OK;
		boolean isValidKey = true;
        try{
			OSDAO dao = new OSDAO();
			
			HashMap parameters = new HashMap();
			if (os.getName()!=null){
				parameters.put(os.getName(), 50);
			} else {
				isValidKey = false;
			}
			if (os.getVersion()!=null){
				parameters.put(os.getVersion(), 50);
			} else {
				isValidKey = false;
			}
			if (os.getDescription()!=null){
				parameters.put(os.getDescription(), 100);
			}
			
			if (!isValidKey || os.getName().length() < 1 || os.getVersion().length() < 1 || !HisUtil.validParas(parameters)){
				status = Response.Status.INTERNAL_SERVER_ERROR;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
						OpenAttestationResponseFault.FaultCode.FAULT_500);
				fault.setError_message("Edit OS entry failed, please check the length for each parameters" +
						" and remove all of the unwanted characters belonged to [# & + : \" \']");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			
			System.out.println("Check if the OEM Name exists:" + os.getName());
			if (!dao.isOSExisted(os.getName(), os.getVersion())){
				status = Response.Status.BAD_REQUEST;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(1006);
				fault.setError_message("Data Error - OS " + os.getName() + os.getVersion() + " don't exists in the database");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			

			
			dao.editOSEntry(os);
	        return Response.status(status).header("Location", b.build()).type(MediaType.TEXT_PLAIN).entity("True")
	        		.build();
		}catch (Exception e){
			status = Response.Status.INTERNAL_SERVER_ERROR;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_500);
			fault.setError_message("Add OS entry failed." + "Exception:" + e.getMessage());
			return Response.status(status).header("Location", b.build()).entity(fault)
					.build();
		}

	}

	@DELETE
	@Produces("application/json")
	public Response delOS(@QueryParam("Name") String Name, @QueryParam("Version") String Version,@Context UriInfo uriInfo){
        UriBuilder b = uriInfo.getBaseUriBuilder();
        b = b.path(OSResource.class);
		Response.Status status = Response.Status.OK;
		boolean isValidKey = true;
		
        try{
			OSDAO dao = new OSDAO();

			HashMap parameters = new HashMap();
			if (Name != null){
				parameters.put(Name, 50);
			} else {
				isValidKey = false;
			}

			if (Version != null){
				parameters.put(Version, 50);
			} else {
				isValidKey = false;
			}
			
			if (!isValidKey || Name.length() < 1 || Version.length() < 1 || !HisUtil.validParas(parameters)){
				status = Response.Status.INTERNAL_SERVER_ERROR;
				OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
						OpenAttestationResponseFault.FaultCode.FAULT_500);
				fault.setError_message("Delete OS entry failed, please check the length for each parameters" +
						" and remove all of the unwanted characters belonged to [# & + : \" \']");
				return Response.status(status).header("Location", b.build()).entity(fault)
						.build();
			}
			
			System.out.println("Check if the OS Name exists:" + Name + " " + Version);
			
			 if (dao.isRefMle(Name, Version)) {
                 status = Response.Status.BAD_REQUEST;
                 OpenAttestationResponseFault fault = new OpenAttestationResponseFault(2012);
                 fault.setError_message("Data Error - OS " + Name + " & Version & " + Version + " reference with MLE, delete failed");
                 return Response.status(status).header("Location", b.build()).entity(fault)
                                 .build();
                 }


			if (dao.isOSExisted(Name, Version)){
				dao.deleteOSEntry(Name, Version);
				return Response.status(status).type(MediaType.TEXT_PLAIN).entity("True")
		        		.build();
			}
			
			status = Response.Status.BAD_REQUEST;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_1006);
			fault.setError_message("Data Error - OS " + Name + Version + " does not exist in the database");		
			return Response.status(status).entity(fault)
					.build();

		}catch (Exception e){
			status = Response.Status.INTERNAL_SERVER_ERROR;
			OpenAttestationResponseFault fault = new OpenAttestationResponseFault(
					OpenAttestationResponseFault.FaultCode.FAULT_500);
			fault.setError_message("Delete OS entry failed." + "Exception:" + e.getMessage()); 
			return Response.status(status).entity(fault)
					.build();

		}
	}
	
	@GET
	@Produces("application/json")
	public List<OS> getOSEntry(@QueryParam("index") String index,
			@QueryParam("CompName") String name,@QueryParam("CompDesc") String desc){
		OSDAO dao = new OSDAO();
		List<OS> emptyList = new ArrayList<OS>();
		if (index == null && name == null && desc == null)
			return dao.getAllOSEntries();
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
