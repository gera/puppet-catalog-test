load "test/test_helper.rb"

class CompleteCatalogTest < PuppetCatalogTestCase
  def test_all_with_working_catalog_should_work
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "working"))

    assert_equal 2, pct.test_cases.size

    result = pct.run_tests!
    assert result

    assert_equal 2, pct.test_cases.select { |tc| tc.passed == true }.size
  end

  def test_all_with_working_catalog_should_have_facts
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "working-with-facts"))

    assert_equal 2, pct.test_cases.size

    result = pct.run_tests!
    assert result

    assert_equal 2, pct.test_cases.select { |tc| tc.passed == true }.size
  end

  def test_all_with_broken_catalog_should_fail
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "failing"))

    assert_equal 2, pct.test_cases.size

    result = pct.run_tests!
    assert !result

    assert_equal 2, pct.test_cases.select { |tc| tc.passed == false }.size
  end

  def test_all_with_filter_should_return_one_match
    filter = PuppetCatalogTest::Filter.new(/foo/)
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "working"), false, filter)

    assert_equal 1, pct.test_cases.size
    assert_equal "foo", pct.test_cases.first.name
  end

  def test_all_with_filter_should_return_no_matches
    filter = PuppetCatalogTest::Filter.new(/talisker/)
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "working"), false, filter)

    assert_equal 0, pct.test_cases.size
  end

  def test_exclude_should_work
    filter = PuppetCatalogTest::Filter.new(/.*/, /foo/)
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "working"), false, filter)

    assert_equal 1, pct.test_cases.size
    assert_equal "default", pct.test_cases.first.name
  end

  def test_on_not_having_fqdn_set_should_fail
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "working"), true)

    result = pct.run_tests!
    assert !result

    assert_equal 2, pct.test_cases.select { |tc| tc.error == "fact 'fqdn' must be defined" }.size
  end

  def test_failed_test_case_should_be_constructed_correct
    pct = build_test_runner_for_all_nodes(File.join(CASE_DIR, "working"), true)
    pct.run_tests!

    tc = pct.test_cases.first

    assert_equal false, tc.passed
    assert_equal "fact 'fqdn' must be defined", tc.error
    assert tc.duration > 0
  end
end
