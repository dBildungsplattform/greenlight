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

import React from "react";
import { Button, Stack } from "react-bootstrap";
import PropTypes from "prop-types";
import { useTranslation } from "react-i18next";
import Spinner from "../../../shared_components/utilities/Spinner";
import useAdminCreateUser from "../../../../hooks/mutations/admin/manage_users/useAdminCreateUser";

export default function UserSignupForm({ handleClose, users, handleStatus }) {
  const { t } = useTranslation();
  const createUserAPI = useAdminCreateUser({ onSettled: () => { } });

  async function handleSubmit() {
    let index = 0;
    for (const user of users) {
      try {
        await createUserAPI.mutateAsync(user);
        handleStatus(index, t("toast.success.user.user_created"));
      } catch (error) {
        if (error.response.data.errors === "EmailAlreadyExists") {
          handleStatus(index, t("toast.error.users.email_exists"));
        } else {
          handleStatus(index, t("toast.error.problem_completing_action"));
        }
      }
      index++;
    }
  }

  return (
    <Stack className="mt-1" direction="horizontal" gap={1}>
      <Button variant="neutral" className="ms-auto" onClick={handleClose}>
        {t("close")}
      </Button>
      <Button
        variant="brand"
        onClick={() => handleSubmit()}
        disabled={createUserAPI.isLoading}
      >
        {createUserAPI.isLoading && <Spinner className="me-2" />}
        {t("admin.manage_users.create_account")}
      </Button>
    </Stack>
  );
}

UserSignupForm.propTypes = {
  handleClose: PropTypes.func,
};

UserSignupForm.defaultProps = {
  handleClose: () => { },
};
