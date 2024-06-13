// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React from 'react';
import { useTranslation } from 'react-i18next';
import useSiteSettings from '../../../../hooks/queries/admin/site_settings/useSiteSettings';
import SettingsRow from '../SettingsRow';
import SettingsRowNumberInput from '../SettingsRowNumberInput';

export default function Settings() {
  const { t } = useTranslation();
  const { data: siteSettings, isLoading } = useSiteSettings(['ShareRooms', 'PreuploadPresentation', 'AutomatedDeletionOfExpiredRooms', 'AutomatedUserBanTime']);
  if (isLoading) return null;

  return (
    <>
      <SettingsRow
        name="ShareRooms"
        title={t('admin.site_settings.settings.allow_users_to_share_rooms')}
        description={(
          <p className="text-muted">
            {t('admin.site_settings.settings.allow_users_to_share_rooms_description')}
          </p>
        )}
        value={siteSettings?.ShareRooms}
      />
      <SettingsRow
        name="PreuploadPresentation"
        title={t('admin.site_settings.settings.allow_users_to_preupload_presentation')}
        description={(
          <p className="text-muted">
            {t('admin.site_settings.settings.allow_users_to_preupload_presentation_description')}
          </p>
        )}
        value={siteSettings?.PreuploadPresentation}
      />
      <SettingsRow
        name="AutomatedDeletionOfExpiredRooms"
        title={t('admin.site_settings.settings.activate_automated_deletion_of_expired_rooms')}
        description={(
          <p className="text-muted">
            {t('admin.site_settings.settings.activate_automated_deletion_of_expired_rooms_description')}
          </p>
        )}
        value={siteSettings?.AutomatedDeletionOfExpiredRooms}
      />
      <SettingsRowNumberInput
        name="AutomatedUserBanTime"
        title={t('admin.site_settings.settings.set_automated_ban_time_from_inactive_users')}
        description={(
          <p className="text-muted">
            {t('admin.site_settings.settings.set_automated_ban_time_from_inactive_users_description')}
          </p>
        )}
        value={siteSettings?.AutomatedUserBanTime}
      />
    </>
  );
}
