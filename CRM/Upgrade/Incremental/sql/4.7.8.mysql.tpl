{* file to handle db changes in 4.7.8 during upgrade *}

#CRM-17967 - Allow conact image file name length during upload up to 255 characters long
ALTER TABLE `civicrm_contact` CHANGE `image_URL` `image_URL` VARCHAR(512) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL COMMENT 'optional URL for preferred image (photo, logo, etc.) to display for this contact.';

-- CRM-16189 Financial account relationship
SELECT @option_group_id_arel           := max(id) from civicrm_option_group where name = 'account_relationship';
SELECT @option_group_id_arel_wt  := MAX(weight) FROM civicrm_option_value WHERE option_group_id = @option_group_id_arel;
SELECT @option_group_id_arel_val := MAX(CAST( `value` AS UNSIGNED )) FROM civicrm_option_value WHERE option_group_id = @option_group_id_arel;
INSERT INTO
   `civicrm_option_value` (`option_group_id`, {localize field='label'}label{/localize}, `value`, `name`, `grouping`, `filter`, `is_default`, `weight`, {localize field='description'}`description`{/localize}, `is_optgroup`, `is_reserved`, `is_active`, `component_id`, `visibility_id`)
VALUES
(@option_group_id_arel, {localize}'{ts escape="sql"}Is Deferred Revenue Account{/ts}'{/localize}, @option_group_id_arel_val+1, 'Is Deferred Revenue Account', NULL, 0, 0, @option_group_id_arel_wt+1, {localize}'Is Deferred Revenue Account'{/localize}, 0, 1, 1, 2, NULL);

-- CRM-16189
ALTER TABLE civicrm_contribution
ADD `revenue_recognition_date` datetime DEFAULT NULL COMMENT 'Stores the date when revenue should be recognized.';
