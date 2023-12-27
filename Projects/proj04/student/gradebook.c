#include "gradebook.h"
#include <string.h>

/*
 * Name: YOUR NAME HERE
 */

struct Gradebook gradebook;

/**
 * Adds a new student to the gradebook and sets all the student's grades to 0.
 *
 * Updates assignment_averages and course_average based on the new grades.
 *
 * @param name The name of the student.
 * @param gtid The GTID of the student.
 * @param year The year of the student.
 * @param major The major of the student.
 * @return SUCCESS if the student is added, otherwise ERROR if the student can't
 * be added (duplicate name / GTID, no space in gradebook, invalid major).
 */
int add_student(char *name, int gtid, int year, char *major) {
  // check for NULL entry
  if (major == NULL) {
    return ERROR;
  }
  // check if gradebook is full
  if (gradebook.size == MAX_ENTRIES) {
    return ERROR;
  }
  // check for duplicate student
  for(int i = 0; i < gradebook.size; i++) {
    if(gradebook.entries[i].student.gtid == gtid){
      return ERROR;
    }
    if(strcmp(gradebook.entries[i].student.name, name) == 0) {
      return ERROR;
    }
  }
  // check length of name
  if (strlen(name) > MAX_NAME_LENGTH) {
    return ERROR;
  }
  struct Student student;
  strcpy(student.name, name);
  student.gtid = gtid;
  student.year = year;

  if (strcmp(major, "CS") == 0) {
     student.major = CS;
  } else if (strcmp(major, "CE") == 0) {
     student.major = CE;
  } else if (strcmp(major, "EE") == 0) {
     student.major = EE;
  } else if (strcmp(major, "IE") == 0) {
     student.major = IE;
  } else {
    return ERROR;
  }

  struct GradebookEntry entry;
  entry.student = student;
  for(int i = 0; i < NUM_ASSIGNMENTS; i++) {
    entry.grades[i] = 0;
  }
  entry.average = 0;

  gradebook.entries[gradebook.size] = entry;

  gradebook.size++;
  
  calculate_course_average();

  return SUCCESS;
}

/**
 * Updates the grade of a specific assignment for a student and updates that
 * student's average grade.
 * 
 * Ensure that the overall course averages are still up-to-date after these grade updates.
 *
 * @param name The name of the student.
 * @param assignmentType The type of assignment.
 * @param newGrade The new grade.
 * @return SUCCESS if the grade is updated, otherwise ERROR if the grade isn't (student not found).
 */
int update_grade(char *name, enum Assignment assignment_type, double new_grade) {
  // find student in gradebook
  // null check
  if (name == NULL) {
    return ERROR;
  }
  int pos;
  for (int i = 0; i < gradebook.size; i++) {
    if (strcmp(gradebook.entries[i].student.name, name) == 0) {
      pos = i; // position of student in gradebook
      break;
    }
    else {
      pos = -1;
    }
  }

  if(pos == -1) {
    return ERROR;
  }

  switch(assignment_type){
    case HW1:
      gradebook.entries[pos].grades[0] = new_grade;
      calculate_average(&gradebook.entries[pos]);
      calculate_course_average();
      break;
    case HW2:
      gradebook.entries[pos].grades[1] = new_grade;
      calculate_average(&gradebook.entries[pos]);
      calculate_course_average();
      break;
    case HW3:
      gradebook.entries[pos].grades[2] = new_grade;
      calculate_average(&gradebook.entries[pos]);
      calculate_course_average();
      break;
    case P1:
      gradebook.entries[pos].grades[3] = new_grade;
      calculate_average(&gradebook.entries[pos]);
      calculate_course_average();
      break;
    case P2:
      gradebook.entries[pos].grades[4] = new_grade;
      calculate_average(&gradebook.entries[pos]);
      calculate_course_average();
      break;
    default:
      return ERROR;
  }
  return SUCCESS;
}

/**
 * Adds a new student to the gradebook and initializes each of the student's
 * grades with the grades passed in.
 *
 * Additionally, will update the overall assignment_averages and course_average
 * based on the new added student.
 *
 * @param name The name of the student.
 * @param gtid The GTID of the student.
 * @param year The year of the student.
 * @param major The major of the student.
 * @param grades An array of grades for the student.
 * @return SUCCESS if the student is added and the averages updated, otherwise ERROR if the student can't
 * be added (duplicate name / GTID, no space in gradebook, invalid major).
 */
int add_student_with_grades(char *name, int gtid, int year, char *major, double *grades) {
  
  //add student to gradebook; default grade entries are 0
  add_student(name, gtid, year, major);

  int student_pos = search_student(name);
  
  if (student_pos == -1) {
    return ERROR;
  } else {
    for (int i = 0; i < NUM_ASSIGNMENTS; i++) {
      gradebook.entries[student_pos].grades[i] = grades[i];
    }
    // calculate student avaerages
    calculate_average(&gradebook.entries[student_pos]);
    // calculate course averages again
    calculate_course_average();

    return SUCCESS;
  }
}

/**
 * Calculates the average grade for a specific gradebook entry and updates the
 * struct as appropriate.
 *
 * @param entry The gradebook entry for which to recalculate the average.
 * @return SUCCESS if the average is updated, ERROR if pointer is NULL
 */
int calculate_average(struct GradebookEntry *entry) {
  // calculate student average in gradebook entry

  // check if gradebook entry is null
  if (entry == NULL) {
    return ERROR;
  }

  // apply weights
  double assignmentAvg = 0;
  for (int i = 0; i < NUM_ASSIGNMENTS; i++) {
    assignmentAvg += ((*entry).grades[i]) * (gradebook.weights[i]);
  }
  (*entry).average = assignmentAvg;
  
  return SUCCESS;
}

/**
 * Calculates and update the overall course average and assignment averages. 
 * The average should be calculated by taking the averages of the student's 
 * averages, NOT the assignment averages.
 *
 * If the gradebook is empty, set the course and assignment averages to 0
 * and return ERROR.
 * 
 * @return SUCCESS if the averages are calculated properly, ERROR if gradebook
 * is empty
 */
int calculate_course_average(void) {

  // check if the gradebook is empty
  if (gradebook.size == 0) {
    // set course average to 0
    gradebook.course_average = 0;
    for (int j = 0; j < NUM_ASSIGNMENTS; j++) {
      gradebook.assignment_averages[j] = 0;
    }
    return ERROR;
  }

  for (int a = 0; a < (NUM_ASSIGNMENTS + 1); a++) {
    double homeworkSum = 0;
    for (int b = 0; b < gradebook.size; b++) {
      homeworkSum += gradebook.entries[b].grades[a];
    }

    homeworkSum = (homeworkSum / gradebook.size);
    gradebook.assignment_averages[a] = homeworkSum;
    
    // student average column
    if (a == NUM_ASSIGNMENTS) {
      double courseAverage = 0;
      for (int i = 0; i < gradebook.size; i++) {
        courseAverage += gradebook.entries[i].average;
      }
      courseAverage = (courseAverage / gradebook.size);
      gradebook.course_average = courseAverage;
    }
  }
  return SUCCESS;
}

/**
 * Searches for a student in the gradebook by name.
 *
 * @param name The name of the student.
 * @return The index of the student in the gradebook, or ERROR if not found.
 */
int search_student(char *name) {

  // null check name
  if (name == NULL) {
    return ERROR;
  }
  for (int i = 0; i < gradebook.size; i++) {
    if (strcmp(gradebook.entries[i].student.name, name) == 0) {
      return i;
    }
  }
  return ERROR;
}

/**
 * Remove a student from the gradebook while maintaining the ordering of the gradebook.
 *
 * Additionally, update the overall assignment_averages and course_average
 * based on the removed student and decrement the size of gradebook.
 *
 * If the gradebook is empty afterwards, SUCCESS should still be returned and
 * averages should be set to 0.
 *
 * @param name The name of the student to be withdrawn.
 * @return SUCCESS if the student is successfully removed, otherwise ERROR if
 * the student isn't found.
 */
int withdraw_student(char *name) {
  int student_pos = search_student(name);

  if (student_pos == -1) {
    return ERROR;
  }
  else {
    // shift previous records down by 1
    while ((student_pos + 1) < gradebook.size) {
      gradebook.entries[student_pos] = gradebook.entries[student_pos + 1];
      student_pos++;
    }
    // if the student is at last index (gradebook.size == pos), just decrement
    gradebook.size--;

    // recalculate course average
    if (gradebook.size == 0) {
      // set assignment averages to 0
      gradebook.course_average = 0;
      for (int i = 0; i < NUM_ASSIGNMENTS; i++) {
        gradebook.assignment_averages[i] = 0;
      }
    } else {
      calculate_course_average();
    }
    return SUCCESS;
  }
}

/**
 * Populate the provided array with the GTIDs of the 5 students with the highest
 * grades. The GTIDs should be placed in descending order of averages. 
 * 
 * If unable to populate the full array (less than 5 students in gradebook), 
 * fill in the remaining values with INVALID_GTID.
 *
 * @param gtids An array to store the top five gtids.
 * @return SUCCESS if gtids are found, otherwise ERROR if gradebook is empty
 */
int top_five_gtid(int *gtids) {
  if (gradebook.size == 0) {
    return ERROR;
  }
  sort_averages();
  for (int i = 0;i < 5; i++) {
    if (i < gradebook.size) {
      gtids[i] = gradebook.entries[i].student.gtid;
    } else {
      gtids[i] = INVALID_GTID; // fill invalid if gradebook.size < 5
    }
  }
  return SUCCESS;
}

/**
 * Sorts the gradebook entries by name in alphabetical order (First, Last).
 *
 * @return SUCCESS if names are sorted, ERROR is gradebook is empty.
 */
int sort_name(void) {
  if (gradebook.size == 0) {
    return ERROR;
  }
  // bubble sort 
  for (int i = gradebook.size; i > 0; i--) {
    for (int j = 0; j < i - 1; j++) {
      int z = 0;
      while (gradebook.entries[j].student.name[z] != '\0' && gradebook.entries[j].student.name[z] == gradebook.entries[j+1].student.name[z]) {
        z++;
      }
      if (gradebook.entries[j].student.name[z] > gradebook.entries[j+1].student.name[z]) {
        struct GradebookEntry tempEntry = gradebook.entries[j];
        gradebook.entries[j] = gradebook.entries[j+1];
        gradebook.entries[j+1] = tempEntry;
      }
    }
  }
  return SUCCESS;
}

/**
 * Sorts the gradebook entries by average grades in descending order.
 *
 * @return SUCCESS if entries are sorted, ERROR if gradebook is empty.
 */
int sort_averages(void) {

  if (gradebook.size == 0) {
    return ERROR;
  }

  for (int i = gradebook.size; i > 0; i--) {
    for (int j = 0; j < i - 1; j++) {
      if (gradebook.entries[j].average < gradebook.entries[j+1].average) {
        struct GradebookEntry tempEntry = gradebook.entries[j];
        gradebook.entries[j] = gradebook.entries[j+1];
        gradebook.entries[j+1] = tempEntry;
      }
    }
  }

  return SUCCESS;
}


/**
 * Prints the entire gradebook in the format
 * student_name,major,grade1,grade2,...,student_average\n
 * 
 * Overall Averages:
 * grade1_average,grade2_average,...,course_average\n
 * 
 * Note 1: The '\n' shouldn’t print, just represents the newline for this example.
 * Note 2: There is an empty line above the “Overall Averages:” line.
 * 
 * All of the floats that you print must be manually rounded to 2 decimal places.
 *
 * @return SUCCESS if gradebook is printed, ERROR if gradebook is empty.
 */
int print_gradebook(void) {
  // check if gradebook is emty or null
  if (gradebook.size == 0) {
    return ERROR;
  }

  for (int i = 0; i < gradebook.size; i++) {
    printf("%s,", gradebook.entries[i].student.name);

    const char* major_strings[] = { "CS", "CE", "EE", "IE" };
    printf("%s,", major_strings[gradebook.entries[i].student.major]);

    for (int j = 0; j < NUM_ASSIGNMENTS; j++) {
      printf("%.2f,", gradebook.entries[i].grades[j]);
    }
    
    printf("%.2f\n", gradebook.entries[i].average);
  }
  printf("\n");

  printf("Overall Averages:\n");
  
  for (int i = 0; i < NUM_ASSIGNMENTS+1; i++) {
    if (i == NUM_ASSIGNMENTS) {
      printf("%.2f\n",gradebook.course_average);

    } else {
      printf("%.2f,",gradebook.assignment_averages[i]);
    }
  }

  return SUCCESS;
}
