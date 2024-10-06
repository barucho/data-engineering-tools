/* let`s look @ explain
*/
use world;
ALTER TABLE  Country DROP index p;

EXPLAIN FORMAT=JSON
SELECT * FROM Country WHERE continent='Asia' and population > 5000000\G
##
{
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "53.80"    ##<=== cost
    },
    "table": {
      "table_name": "Country",
      "access_type": "ALL",   ## <== FULL TABLE Scan
      "rows_examined_per_scan": 239,  #Accessing all 239 rows in the table
      "rows_produced_per_join": 11,
      "filtered": "4.76",
      "cost_info": {
        "read_cost": "51.52",
        "eval_cost": "2.28",
        "prefix_cost": "53.80",
        "data_read_per_join": "2K"
      },
      "used_columns": [     ## this is the select * ..
        "Code",
        "Name",
        "Continent",
        "Region",
        "SurfaceArea",
        "IndepYear",
        "Population",
        "LifeExpectancy",
        "GNP",
        "GNPOld",
        "LocalName",
        "GovernmentForm",
        "HeadOfState",
        "Capital",
        "Code2"
      ],
      "attached_condition": "((`world`.`country`.`Continent` = 'Asia') and (`world`.`country`.`Population` > 5000000))"  ## filter will be applied when reading the rows
    }
  }
}


--# adding index to population
ALTER TABLE Country ADD INDEX p (population);

EXPLAIN FORMAT=JSON
SELECT * FROM Country WHERE continent='Asia' and population > 5000000;

##
{
  "query_block": {
    "select_id": 1,
    "cost_info": {
      "query_cost": "53.80" ##<=== cost
    },
    "table": {
      "table_name": "Country",
      "access_type": "ALL",  ## the optimizer select FTS but
      "possible_keys": [   ## now we have possible_keys with the index p ...
        "p"            ##
      ],
      "rows_examined_per_scan": 239,
      "rows_produced_per_join": 15,
      "filtered": "6.46",
      "cost_info": {
        "read_cost": "50.71",
        "eval_cost": "3.09",
        "prefix_cost": "53.80",
        "data_read_per_join": "3K"
      },
      "used_columns": [
        "Code",
        "Name",
        "Continent",
        "Region",
        "SurfaceArea",
        "IndepYear",
        "Population",
        "LifeExpectancy",
        "GNP",
        "GNPOld",
        "LocalName",
        "GovernmentForm",
        "HeadOfState",
        "Capital",
        "Code2"
      ],
      "attached_condition": "((`world`.`country`.`Continent` = 'Asia') and (`world`.`country`.`Population` > 5000000))"
    }
  }
}
/*
#OPTIMIZER_TRACE
# lets enable optimizer trace*/
SET optimizer_trace_offset=-10, optimizer_trace_limit=10;
SET optimizer_trace="enabled=on";
--##run query
SELECT  * FROM Country WHERE continent='Asia' and population > 5000000;
--## look @ table
SELECT * FROM information_schema.optimizer_trace;

--#
SET optimizer_trace="enabled=off";

##OPTIMIZER_TRACE showing why the index was not used
{
  "steps": [
    {
      "join_preparation": {
        "select#": 1,
        "steps": [
          {
            "expanded_query": "/* select#1 */ select `country`.`Code` AS `Code`,`country`.`Name` AS `Name`,`country`.`Continent` AS `Continent`,`country`.`Region` AS `Region`,`country`.`SurfaceArea` AS `SurfaceArea`,`country`.`IndepYear` AS `IndepYear`,`country`.`Population` AS `Population`,`country`.`LifeExpectancy` AS `LifeExpectancy`,`country`.`GNP` AS `GNP`,`country`.`GNPOld` AS `GNPOld`,`country`.`LocalName` AS `LocalName`,`country`.`GovernmentForm` AS `GovernmentForm`,`country`.`HeadOfState` AS `HeadOfState`,`country`.`Capital` AS `Capital`,`country`.`Code2` AS `Code2` from `country` where ((`country`.`Continent` = 'Asia') and (`country`.`Population` > 5000000))"
          }
        ]
      }
    },
    {
      "join_optimization": {
        "select#": 1,
        "steps": [
          {
            "condition_processing": {
              "condition": "WHERE",
              "original_condition": "((`country`.`Continent` = 'Asia') and (`country`.`Population` > 5000000))",
              "steps": [
                {
                  "transformation": "equality_propagation",
                  "resulting_condition": "((`country`.`Population` > 5000000) and multiple equal('Asia', `country`.`Continent`))"
                },
                {
                  "transformation": "constant_propagation",
                  "resulting_condition": "((`country`.`Population` > 5000000) and multiple equal('Asia', `country`.`Continent`))"
                },
                {
                  "transformation": "trivial_condition_removal",
                  "resulting_condition": "((`country`.`Population` > 5000000) and multiple equal('Asia', `country`.`Continent`))"
                }
              ]
            }
          },
          {
            "substitute_generated_columns": {
            }
          },
          {
            "table_dependencies": [
              {
                "table": "`country`",
                "row_may_be_null": false,
                "map_bit": 0,
                "depends_on_map_bits": [
                ]
              }
            ]
          },
          {
            "ref_optimizer_key_uses": [
            ]
          },
          {
            "rows_estimation": [
              {
                "table": "`country`",
                "range_analysis": {
                  "table_scan": {
                    "rows": 239,
                    "cost": 55.9
                  },
                  "potential_range_indexes": [
                    {
                      "index": "PRIMARY",
                      "usable": false,
                      "cause": "not_applicable"
                    },
                    {
                      "index": "p",
                      "usable": true,
                      "key_parts": [
                        "Population",
                        "Code"
                      ]
                    }
                  ],
                  "setup_range_conditions": [
                  ],
                  "group_index_range": {
                    "chosen": false,
                    "cause": "not_group_by_or_distinct"
                  },
                  "analyzing_range_alternatives": {
                    "range_scan_alternatives": [
                      {
                        "index": "p",     ## what if i use index ?
                        "ranges": [
                          "5000000 < Population"
                        ],
                        "index_dives_for_eq_ranges": true,
                        "rowid_ordered": false,
                        "using_mrr": false,
                        "index_only": false,
                        "rows": 108,
                        "cost": 130.61,   ## cost for using index
                        "chosen": false,  ## can not use
                        "cause": "cost"   ### cost to high
                      }
                    ],
                    "analyzing_roworder_intersect": {
                      "usable": false,                    # Merging indexes is rejected
                      "cause": "too_few_roworder_scans"
                    }
                  }
                }
              }
            ]
          },
          {
            "considered_execution_plans": [
              {
                "plan_prefix": [
                ],
                "table": "`country`",
                "best_access_path": {
                  "considered_access_paths": [
                    {
                      "rows_to_scan": 239,
                      "access_type": "scan",
                      "resulting_rows": 239,
                      "cost": 53.8,
                      "chosen": true
                    }
                  ]
                },
                "condition_filtering_pct": 100,
                "rows_for_plan": 239,
                "cost_for_plan": 53.8,
                "chosen": true
              }
            ]
          },
          {
            "attaching_conditions_to_tables": {
              "original_condition": "((`country`.`Continent` = 'Asia') and (`country`.`Population` > 5000000))",
              "attached_conditions_computation": [
              ],
              "attached_conditions_summary": [
                {
                  "table": "`country`",
                  "attached": "((`country`.`Continent` = 'Asia') and (`country`.`Population` > 5000000))"
                }
              ]
            }
          },
          {
            "refine_plan": [
              {
                "table": "`country`"
              }
            ]
          }
        ]
      }
    },
    {
      "join_execution": {
        "select#": 1,
        "steps": [
        ]
      }
    }
  ]
}
--##


/*
The optimizer_search_depth variable tells how far into the “future” of each 
incomplete plan the optimizer should look to evaluate whether it should be expanded further
If you are unsure of what a reasonable value is for optimizer_search_depth,
this variable can be set to 0 to tell the optimizer to determine the value automatically.
*/

select @@optimizer_search_depth;

--## cost

select * from  mysql.server_cost;

--## change cost
--# Increase the cost from 0.2 to 1.0
UPDATE mysql.server_cost SET cost_value=1 WHERE cost_name='row_evaluate_cost';
FLUSH OPTIMIZER_COSTS;

--### in new session
EXPLAIN FORMAT=JSON
SELECT * FROM Country WHERE continent='Asia' and population > 5000000;



--# fix all 
UPDATE mysql.server_cost SET cost_value=NULL WHERE cost_name='row_evaluate_cost'; 
FLUSH OPTIMIZER_COSTS; 











