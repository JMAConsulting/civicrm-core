{* file to handle db changes in 4.7.alpha1 during upgrade *}

-- CRM-16354
SELECT @option_group_id_wysiwyg := max(id) from civicrm_option_group where name = 'wysiwyg_editor';

UPDATE civicrm_option_value SET name = 'Textarea', {localize field='label'}label = 'Textarea'{/localize}
  WHERE value = 1 AND option_group_id = @option_group_id_wysiwyg;

DELETE FROM civicrm_option_value WHERE name IN ('Joomla Default Editor', 'Drupal Default Editor')
  AND option_group_id = @option_group_id_wysiwyg;

UPDATE civicrm_option_value SET is_active = 1, is_reserved = 1 WHERE option_group_id = @option_group_id_wysiwyg;

--CRM-16719
SELECT @option_group_id_report := max(id) from civicrm_option_group where name = 'report_template';

UPDATE civicrm_option_value SET {localize field="label"}label = 'Activity Details Report'{/localize}
  WHERE value = 'activity' AND option_group_id = @option_group_id_report;

UPDATE civicrm_option_value SET {localize field="label"}label = 'Activity Summary Report'{/localize}
  WHERE value = 'activitySummary' AND option_group_id = @option_group_id_report;

--CRM-16853 PCP Owner Notification

{include file='../CRM/Upgrade/4.7.alpha1.msg_template/civicrm_msg_template.tpl'}

-- CRM-16478 Remove custom fatal error template path
DELETE FROM civicrm_setting WHERE name = 'fatalErrorTemplate';

UPDATE civicrm_state_province SET name = 'Bataan' WHERE name = 'Batasn';

--CRM-16914
ALTER TABLE civicrm_payment_processor
ADD COLUMN
`payment_instrument_id` int unsigned   DEFAULT 1 COMMENT 'Payment Instrument ID';

ALTER TABLE civicrm_payment_processor_type
ADD COLUMN
`payment_instrument_id` int unsigned   DEFAULT 1 COMMENT 'Payment Instrument ID';

-- CRM-16876 Set country names to UPPERCASE
UPDATE civicrm_country SET `name` = UPPER( `name` );

-- CRM-16447
UPDATE civicrm_state_province SET name = 'Northern Ostrobothnia' WHERE name = 'Nothern Ostrobothnia';

-- CRM-14078
UPDATE civicrm_option_group SET {localize field="title"}title = '{ts escape="sql"}Payment Methods{/ts}'{/localize} WHERE name = 'payment_instrument';
UPDATE civicrm_navigation SET label = '{ts escape="sql"}Payment Methods{/ts}' WHERE name = 'Payment Instruments';

-- CRM-16176
{if $multilingual}
  {foreach from=$locales item=locale}
     ALTER TABLE civicrm_relationship_type ADD label_a_b_{$locale} varchar(64);
     ALTER TABLE civicrm_relationship_type ADD label_b_a_{$locale} varchar(64);
     ALTER TABLE civicrm_relationship_type ADD description_{$locale} varchar(255);

     UPDATE civicrm_relationship_type SET label_a_b_{$locale} = label_a_b;
     UPDATE civicrm_relationship_type SET label_b_a_{$locale} = label_b_a;
     UPDATE civicrm_relationship_type SET description_{$locale} = description;
  {/foreach}

  ALTER TABLE civicrm_relationship_type DROP label_a_b;
  ALTER TABLE civicrm_relationship_type DROP label_b_a;
  ALTER TABLE civicrm_relationship_type DROP description;
{/if}

-- Added is_payment flag 
ALTER TABLE civicrm_financial_trxn ADD COLUMN is_payment tinyint(4) DEFAULT '0' COMMENT 'Is this entry either a payment or a reversal of a payment?';

-- Add payments user dashboard option

SELECT @option_group_id_dash := MAX(id) from civicrm_option_group where name = 'user_dashboard_options';
SELECT @option_group_id_dash_wt := MAX(weight) FROM civicrm_option_value WHERE option_group_id = @option_group_id_dash;
SELECT @option_group_id_dash_val := MAX(CAST( `value` AS UNSIGNED )) FROM civicrm_option_value WHERE option_group_id = @option_group_id_dash;

INSERT INTO
`civicrm_option_value` (`option_group_id`, {localize field='label'}`label`{/localize}, `value`, `name`, `grouping`, `filter`, `is_default`, `weight`, `is_optgroup`, `is_reserved`, `is_active`, `component_id`, `visibility_id`)
VALUES
(@option_group_id_dash, {localize}'{ts escape="sql"}Payments{/ts}'{/localize}, @option_group_id_dash_val+1, 'Payments', NULL, NULL, NULL, @option_group_id_dash_wt+1, 0, 0, 1, NULL, NULL);
