# Copyright 2012 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
#
# Copyright 2012 Nebula, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.


import MySQLdb
import os

from django.utils.translation import ugettext_lazy as _

from horizon import exceptions
from horizon import forms
from horizon import workflows

from openstack_dashboard import api
from openstack_dashboard.utils import filters

INDEX_URL = "horizon:projects:instances:index"
ADD_USER_URL = "horizon:projects:instances:create_user"
INSTANCE_SEC_GROUP_SLUG = "update_security_groups"
INSTANCE_PROTECTION_SLUG = "update_protection"

def get_protection(uuid):
    db = MySQLdb.connect(host="localhost", port = 3306, user= "root", passwd="password", db="nova")
    cursor = db.cursor()
    cursor.execute("""SELECT protection, uuid FROM instances WHERE uuid=%s""", (uuid))
    results = cursor.fetchall()
    cursor.close()
    db.close()
    return results[0][0]


class UpdateInstanceSecurityGroupsAction(workflows.MembershipAction):
    def __init__(self, request, *args, **kwargs):
        super(UpdateInstanceSecurityGroupsAction, self).__init__(request,
                                                                 *args,
                                                                 **kwargs)
        err_msg = _('Unable to retrieve security group list. '
                    'Please try again later.')
        context = args[0]
        instance_id = context.get('instance_id', '')

        default_role_name = self.get_default_role_field_name()
        self.fields[default_role_name] = forms.CharField(required=False)
        self.fields[default_role_name].initial = 'member'

        # Get list of available security groups
        all_groups = []
        try:
            all_groups = api.network.security_group_list(request)
        except Exception:
            exceptions.handle(request, err_msg)
        groups_list = [(group.id, group.name) for group in all_groups]

        instance_groups = []
        try:
            instance_groups = api.network.server_security_groups(request,
                                                                 instance_id)
        except Exception:
            exceptions.handle(request, err_msg)
        field_name = self.get_member_field_name('member')
        self.fields[field_name] = forms.MultipleChoiceField(required=False)
        self.fields[field_name].choices = groups_list
        self.fields[field_name].initial = [group.id
                                           for group in instance_groups]

    def handle(self, request, data):
        instance_id = data['instance_id']
        wanted_groups = map(filters.get_int_or_uuid, data['wanted_groups'])
        try:
            api.network.server_update_security_groups(request, instance_id,
                                                      wanted_groups)
        except Exception as e:
            exceptions.handle(request, str(e))
            return False
        return True

    class Meta(object):
        name = _("Security Groups")
        slug = INSTANCE_SEC_GROUP_SLUG


class UpdateInstanceSecurityGroups(workflows.UpdateMembersStep):
    action_class = UpdateInstanceSecurityGroupsAction
    help_text = _("Add and remove security groups to this instance "
                  "from the list of available security groups.")
    available_list_title = _("All Security Groups")
    members_list_title = _("Instance Security Groups")
    no_available_text = _("No security groups found.")
    no_members_text = _("No security groups enabled.")
    show_roles = False
    depends_on = ("instance_id",)
    contributes = ("wanted_groups",)

    def contribute(self, data, context):
        request = self.workflow.request
        if data:
            field_name = self.get_member_field_name('member')
            context["wanted_groups"] = request.POST.getlist(field_name)
        return context


class UpdateInstanceProtectionAction(workflows.MembershipAction):
    def __init__(self, request, *args, **kwargs):
        super(UpdateInstanceProtectionAction, self).__init__(request,
                                                                *args,
                                                                 **kwargs)
        err_msg = _('Unable to retrieve protection service list. '
                    'Please try again later.')
        context = args[0]
        instance_id = context.get('instance_id', '')

        default_role_name = self.get_default_role_field_name()
        self.fields[default_role_name] = forms.CharField(required=False)
        self.fields[default_role_name].initial = 'member'

        groups_list = []

        groups_list.append(("1", "Syscall Integrity Checking"))
        groups_list.append(("2", "IDT Integrity Checking"))
        groups_list.append(("3", "Procfs Integrity Checking"))
        groups_list.append(("4", "Hidden Process Detection"))
        groups_list.append(("5", "Program Launch Checking"))
        groups_list.append(("6", "Kernel Driver Monitoring"))
        groups_list.append(("7", "Network Socket Monitoring"))

        instance_protection = []
        try:
            protection = get_protection(instance_id)
            if not protection == None:
                protectionList = list(protection)
                instance_protection = [str(i+1) for i in range(len(protectionList)) if protectionList[i] == "1"]
        except Exception:
            exceptions.handle(request, err_msg)

        field_name = self.get_member_field_name('member')
        self.fields[field_name] = forms.MultipleChoiceField(required=False)
        self.fields[field_name].choices = groups_list
        self.fields[field_name].initial = [protection_id for protection_id in instance_protection]

    def handle(self, request, data):
        wanted_protection = map(filters.get_int_or_uuid, data['wanted_protection'])
        try:
            api.nova.server_change_protection(request, data['instance_id'], wanted_protection)
        except Exception as e:
            exceptions.handle(request, str(e))
            return False
        return True

    class Meta(object):
        name = _("Protection")
        slug = INSTANCE_PROTECTION_SLUG


class UpdateInstanceProtection(workflows.UpdateMembersStep):
    action_class = UpdateInstanceProtectionAction
    help_text = _("Add and remove protection to this instance "
                  "from the list of available protection services.")
    available_list_title = _("All Protection Services")
    members_list_title = _("Instance Protection Services")
    no_available_text = _("No protection services found.")
    no_members_text = _("No protection services enabled.")
    depends_on = ("instance_id",)
    contributes = ("wanted_protection",)

    def contribute(self, data, context):
        request = self.workflow.request
        if data:
            field_name = self.get_member_field_name('member')
            context["wanted_protection"] = request.POST.getlist(field_name)
        return context

class UpdateInstanceInfoAction(workflows.Action):
    name = forms.CharField(label=_("Name"),
                           max_length=255)

    def handle(self, request, data):
        try:
            api.nova.server_update(request,
                                   data['instance_id'],
                                   data['name'])
        except Exception:
            exceptions.handle(request, ignore=True)
            return False
        return True

    class Meta(object):
        name = _("Information")
        slug = 'instance_info'
        help_text = _("Edit the instance details.")

class UpdateInstanceInfo(workflows.Step):
    action_class = UpdateInstanceInfoAction
    depends_on = ("instance_id",)
    contributes = ("name",)


class UpdateInstance(workflows.Workflow):
    slug = "update_instance"
    name = _("Edit Instance")
    finalize_button_name = _("Save")
    success_message = _('Modified instance "%s".')
    failure_message = _('Unable to modify instance "%s".')
    success_url = "horizon:project:instances:index"
    default_steps = (UpdateInstanceInfo,
                     UpdateInstanceSecurityGroups,
                     UpdateInstanceProtection)

    def format_status_message(self, message):
        return message % self.context.get('name', 'unknown instance')


# NOTE(kspear): nova doesn't support instance security group management
#               by an admin. This isn't really the place for this code,
#               but the other ways of special-casing this are even messier.
class AdminUpdateInstance(UpdateInstance):
    success_url = "horizon:admin:instances:index"
    default_steps = (UpdateInstanceInfo,)
