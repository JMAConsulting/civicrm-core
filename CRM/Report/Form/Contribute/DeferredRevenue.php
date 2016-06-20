<?php
/*
 +--------------------------------------------------------------------+
 | CiviCRM version 4.7                                                |
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC (c) 2004-2016                                |
 +--------------------------------------------------------------------+
 | This file is a part of CiviCRM.                                    |
 |                                                                    |
 | CiviCRM is free software; you can copy, modify, and distribute it  |
 | under the terms of the GNU Affero General Public License           |
 | Version 3, 19 November 2007 and the CiviCRM Licensing Exception.   |
 |                                                                    |
 | CiviCRM is distributed in the hope that it will be useful, but     |
 | WITHOUT ANY WARRANTY; without even the implied warranty of         |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               |
 | See the GNU Affero General Public License for more details.        |
 |                                                                    |
 | You should have received a copy of the GNU Affero General Public   |
 | License and the CiviCRM Licensing Exception along                  |
 | with this program; if not, contact CiviCRM LLC                     |
 | at info[AT]civicrm[DOT]org. If you have questions about the        |
 | GNU Affero General Public License or the licensing of CiviCRM,     |
 | see the CiviCRM license FAQ at http://civicrm.org/licensing        |
 +--------------------------------------------------------------------+
 */

/**
 *
 * @package CRM
 * @copyright CiviCRM LLC (c) 2004-2016
 * $Id$
 *
 */
class CRM_Report_Form_Contribute_DeferredRevenue extends CRM_Report_Form {

  /**
   */
  public function __construct() {
    $this->_autoIncludeIndexedFieldsAsOrderBys = 1;
    $this->_columns = array(
      'civicrm_financial_account' => array(
        'dao' => 'CRM_Financial_DAO_FinancialAccount',
        'filters' => array(
          'id' => array(
            'title' => ts('Deferred Financial Account'),
            'operatorType' => CRM_Report_Form::OP_MULTISELECT,
            'options' => CRM_Financial_BAO_FinancialAccount::getAllDeferredFinancialAccount(),
            'type' => CRM_Utils_Type::T_INT,
          ),
        ),
      ),
    );
    parent::__construct();
  }

  public function preProcess() {
    parent::preProcess();
  }

  public function select() {
    $this->_select = ' SELECT 
financial_account_deferred.name,
financial_account_deferred.accounting_code,
financial_account_revenue.name,
financial_account_revenue.accounting_code
';
  }

  public function from() {
    $this->_from = " FROM civicrm_entity_financial_account entity_financial_account_deferred
INNER JOIN civicrm_financial_account financial_account_deferred
  ON entity_financial_account_deferred.financial_account_id = financial_account_deferred.id
INNER JOIN civicrm_option_value option_value_deferred
  ON option_value_deferred.value = entity_financial_account_deferred.account_relationship AND option_value_deferred.name = 'Deferred Revenue Account is'
INNER JOIN civicrm_option_group option_group_deferred
  ON option_group_deferred.id = option_value_deferred.option_group_id AND option_group_deferred.name = 'account_relationship'
INNER JOIN civicrm_entity_financial_account entity_financial_account_revenue
  ON entity_financial_account_deferred.entity_id = entity_financial_account_revenue.entity_id 
    AND entity_financial_account_deferred.entity_table= entity_financial_account_revenue.entity_table 
INNER JOIN civicrm_financial_account financial_account_revenue
  ON entity_financial_account_revenue.financial_account_id = financial_account_revenue.id 
INNER JOIN civicrm_option_value option_value_revenue
  ON option_value_revenue.value = entity_financial_account_revenue.account_relationship 
    AND option_group_deferred.id = option_value_revenue.option_group_id AND option_value_revenue.name = 'Income Account is'
";
  }

  public function orderBy() {
    parent::orderBy();
  }

  public function where() {
    $clauses = array("entity_financial_account_deferred.entity_table = 'civicrm_financial_type'");
    foreach ($this->_columns as $tableName => $table) {
      if (array_key_exists('filters', $table)) {
        foreach ($table['filters'] as $fieldName => $field) {
          $clause = NULL;
          if (CRM_Utils_Array::value('type', $field) & CRM_Utils_Type::T_DATE) {
            $relative = CRM_Utils_Array::value("{$fieldName}_relative", $this->_params);
            $from = CRM_Utils_Array::value("{$fieldName}_from", $this->_params);
            $to = CRM_Utils_Array::value("{$fieldName}_to", $this->_params);

            $clause = $this->dateClause($field['name'], $relative, $from, $to, $field['type']);
          }
          else {
            $op = CRM_Utils_Array::value("{$fieldName}_op", $this->_params);
            if ($op) {
              $clause = $this->whereClause($field,
                $op,
                CRM_Utils_Array::value("{$fieldName}_value", $this->_params),
                CRM_Utils_Array::value("{$fieldName}_min", $this->_params),
                CRM_Utils_Array::value("{$fieldName}_max", $this->_params)
              );
            }
          }
          if (!empty($clause)) {
            $clauses[] = $clause;
          }
        }
      }
    }
    $this->_where = 'WHERE ' . implode(' AND ', $clauses);
  }

  public function postProcess() {
    parent::postProcess();
  }

  public function groupBy() {
    $this->_groupBy = "GROUP BY financial_account_deferred.id, financial_account_revenue.id";
  }

  /**
   * @param $rows
   *
   * @return array
   */
  public function statistics(&$rows) {}

  /**
   * Alter display of rows.
   *
   * Iterate through the rows retrieved via SQL and make changes for display purposes,
   * such as rendering contacts as links.
   *
   * @param array $rows
   *   Rows generated by SQL, with an array for each row.
   */
  public function alterDisplay(&$rows) {}

}
