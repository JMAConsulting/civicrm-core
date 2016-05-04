{* file to handle db changes in 4.7.8 during upgrade *}

#CRM-17967 - Allow conact image file name length during upload up to 255 characters long
ALTER TABLE `civicrm_contact` CHANGE `image_URL` `image_URL` VARCHAR(512) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL COMMENT 'optional URL for preferred image (photo, logo, etc.) to display for this contact.';

-- CRM-18516 Convert the date fields relating to group caching and acl caching timestamp
ALTER TABLE civicrm_group CHANGE cache_date cache_date timestamp NULL DEFAULT NULL , CHANGE refresh_date refresh_date timestamp NULL DEFAULT NULL;
ALTER TABLE civicrm_acl_cache CHANGE modified_date modified_date timestamp NULL DEFAULT NULL;

-- CRM-18537
DELETE FROM civicrm_state_province WHERE name = 'Fernando de Noronha';

-- CRM-17118 extend civicrm_address postal_code to accept full data strings from paypal etc.
ALTER TABLE civicrm_address CHANGE `postal_code` `postal_code` varchar(64) ;

-- CRM-16189 Financial account relationship
SELECT @option_group_id_arel           := max(id) from civicrm_option_group where name = 'account_relationship';
SELECT @option_group_id_arel_wt  := MAX(weight) FROM civicrm_option_value WHERE option_group_id = @option_group_id_arel;
SELECT @option_group_id_arel_val := MAX(CAST( `value` AS UNSIGNED )) FROM civicrm_option_value WHERE option_group_id = @option_group_id_arel;
INSERT INTO
   `civicrm_option_value` (`option_group_id`, {localize field='label'}label{/localize}, `value`, `name`, `grouping`, `filter`, `is_default`, `weight`, {localize field='description'}`description`{/localize}, `is_optgroup`, `is_reserved`, `is_active`, `component_id`, `visibility_id`)
VALUES
(@option_group_id_arel, {localize}'{ts escape="sql"}Is Deferred Revenue Account{/ts}'{/localize}, @option_group_id_arel_val+1, 'Is Deferred Revenue Account', NULL, 0, 0, @option_group_id_arel_wt+1, {localize}'Is Deferred Revenue Account'{/localize}, 0, 1, 1, 2, NULL);
