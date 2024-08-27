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

namespace Civi\Api4\Generic;

use Civi\API\Exception\UnauthorizedException;
use Civi\Api4\Utils\CoreUtil;
use Civi\Api4\Utils\ReflectionUtils;
use Civi\Schema\EntityProvider;

/**
 * Delete one or more $ENTITIES.
 *
 * $ENTITIES are deleted based on criteria specified in `where` parameter (required).
 */
class DAODeleteAction extends AbstractBatchAction {
  use Traits\DAOActionTrait;

  /**
   * Batch delete function
   */
  public function _run(Result $result) {
    $defaults = $this->getParamDefaults();
    if ($defaults['where'] && $this->where === $defaults['where']) {
      throw new \CRM_Core_Exception('Cannot delete ' . $this->getEntityName() . ' with no "where" parameter specified');
    }

    $items = $this->getBatchRecords();

    if ($this->getCheckPermissions()) {
      $idField = CoreUtil::getIdFieldName($this->getEntityName());
      foreach ($items as $key => $item) {
        // Don't pass the entire item because only the id is a trusted value
        if (!CoreUtil::checkAccessRecord($this, [$idField => $item[$idField]], \CRM_Core_Session::getLoggedInContactID() ?: 0)) {
          throw new UnauthorizedException("ACL check failed");
        }
        $items[$key]['check_permissions'] = TRUE;
      }
    }
    if ($items) {
      $result->exchangeArray($this->deleteObjects($items));
    }
  }

  /**
   * @param $items
   * @return array
   * @throws \CRM_Core_Exception
   */
  protected function deleteObjects($items) {
    return new EntityProvider($this->getEntityName())->deleteRecords($items);
  }

}
