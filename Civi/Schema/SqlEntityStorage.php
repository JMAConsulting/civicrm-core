<?php
/*
 +--------------------------------------------------------------------+
 | Copyright CiviCRM LLC. All rights reserved.                        |
 |                                                                    |
 | This work is published under the GNU AGPLv3 license with some      |
 | permitted exceptions and without any warranty. For full license    |
 | and copyright information, see https://civicrm.org/licensing       |
 +--------------------------------------------------------------------+
 */

namespace Civi\Schema;

use Civi\Api4\Utils\CoreUtil;
use Civi\Api4\Utils\ReflectionUtils;

class SqlEntityStorage implements EntityStorageInterface {

  /**
   * @var string
   */
  protected string $entityName;
  
  /**
   * @var string
   */
  protected string $baoName;

  public function __construct(string $entityName) {
    $this->entityName = $entityName;
    $this->baoName = CoreUtil::getBAOFromApiName($entityName);
  }

  public function writeRecords(array $records): array {
    $saved = [];
    $baoName = $this->baoName;

    $method = method_exists($baoName, 'create') ? 'create' : (method_exists($baoName, 'add') ? 'add' : NULL);
    // Use BAO create or add method if not deprecated
    if ($method && !ReflectionUtils::isMethodDeprecated($baoName, $method)) {
      foreach ($items as $item) {
        $saved[] = $baoName::$method($item);
      }
    }
    else {
      $saved = $baoName::writeRecords($items);
    }
    return $saved;
  }

  public function deleteRecords(array $records): array {
    $idField = CoreUtil::getIdFieldName($this->entityName);
    $result = [];
    $baoName = $this->baoName;

    // Use BAO::del() method if it is not deprecated
    if (method_exists($baoName, 'del') && !ReflectionUtils::isMethodDeprecated($baoName, 'del')) {
      foreach ($records as $record) {
        $args = [$record[$idField]];
        $bao = call_user_func_array([$baoName, 'del'], $args);
        if ($bao !== FALSE) {
          $result[] = [$idField => $record[$idField]];
        }
        else {
          throw new \CRM_Core_Exception("Could not delete {$this->entityName} $idField {$record[$idField]}");
        }
      }
    }
    else {
      foreach ($baoName::deleteRecords($records) as $instance) {
        $result[] = [$idField => $instance->$idField];
      }
    }
    return $result;
  }
  
  public function validateRecords(array $records, $action): array {
    $baoName = $this->baoName;
    $errors = [];
    
    if (method_exists($baoName, 'validate')) {
      foreach ($records as $record) {
        $errors[] = $baoName::validate($record, $action);
        \CRM_Utils_Hook::validate($entityName, $record, $action, $errors);
      }
    }
    
    return $errors;
  }

}
