#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Tests for the GIFT PPA script writer."""

from __future__ import unicode_literals

import unittest

from l2tdevtools import dependencies
from l2tdevtools.dependency_writers import gift_ppa
from l2tdevtools.helpers import project
from tests import test_lib


class GIFTPPAInstallTest(test_lib.BaseTestCase):
  """Tests the gift_ppa_install.py writer."""

  def testInitialize(self):
    """Tests that the writer can be initialized."""

    l2tdevtools_path = '/fake/l2tdevtools/'
    project_definition = project.ProjectHelper(l2tdevtools_path)
    configuration_file = self._GetTestFilePath(['dependencies.ini'])
    dependency_helper = dependencies.DependencyHelper(
        configuration_file=configuration_file)

    writer = gift_ppa.GIFTPPAInstallScriptWriter(
        l2tdevtools_path, project_definition, dependency_helper)
    self.assertIsNotNone(writer)

  # TODO: Add test for the Write method.


if __name__ == '__main__':
  unittest.main()
