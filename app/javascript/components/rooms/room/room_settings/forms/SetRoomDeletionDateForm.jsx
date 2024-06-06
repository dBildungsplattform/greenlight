
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

/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import {
  Button, Row, Stack, Form,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import useRoom from '../../../../../hooks/queries/rooms/useRoom';
import useUpdateRoom from '../../../../../hooks/mutations/rooms/useUpdateRoom';

export default function SetRoomDeletionDateForm({ friendlyId }) {
  const { t } = useTranslation();
  const {
    register,
    handleSubmit,
  } = useForm();
  const { data: room } = useRoom(friendlyId);
  const updateRoom = useUpdateRoom({ friendlyId });
  const onSubmit = (data) => {
    updateRoom.mutate({ deletion_date: data.room.deletion_date });
  };

  const formattedDate = (date) => {
    const d = new Date(date);
    return d.toISOString().split('T')[0];
  };

  return (
    <Row>
      <h6 className="text-brand"> {t('admin.room_configuration.room_deletion_date')}</h6>
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Stack direction="horizontal" className='w-400'>
          <Form.Control type="date"  {...(room.deletion_date && { defaultValue: formattedDate(room.deletion_date) })}  {...register('room.deletion_date')} />
          <Button type="submit" variant="brand" className="ms-3">  {room.deletion_date ? t('update') : t('save')} </Button>
        </Stack>
      </Form>

    </Row>
  );
}

SetRoomDeletionDateForm.propTypes = {
  friendlyId: PropTypes.string.isRequired,
};
